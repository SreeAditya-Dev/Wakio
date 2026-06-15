import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/dio_client.dart';
import '../../core/services/alarm_service.dart';
import '../../core/storage/app_database.dart';
import '../models/alarm_x.dart';
import 'challenge_repository.dart';

/// Offline-first alarm CRUD: Drift is the source of truth, the OS alarm is
/// (re)scheduled on every change, and writes are pushed to the backend best-effort.
class AlarmRepository {
  AlarmRepository(this._db, this._alarmService, this._dio, this._challenges);

  final AppDatabase _db;
  final AlarmService _alarmService;
  final Dio _dio;
  final ChallengeRepository _challenges;
  static const _uuid = Uuid();

  Stream<List<Alarm>> watch() => _db.watchAlarms();

  Future<Alarm> saveDraft({
    String? id,
    required String label,
    required TimeOfDay time,
    required List<int> repeatDays,
    String challengeType = 'object_scan',
    int volume = 100,
    int snoozeMinutes = 5,
    bool vibrate = true,
    bool enabled = true,
  }) async {
    final alarmId = id ?? _uuid.v4();
    final existing = id != null ? await _db.alarmById(id) : null;
    final scheduledId =
        existing?.scheduledId ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);

    final companion = AlarmsCompanion(
      id: Value(alarmId),
      label: Value(label),
      hour: Value(time.hour),
      minute: Value(time.minute),
      repeatDays: Value(repeatDays.join(',')),
      challengeType: Value(challengeType),
      volume: Value(volume),
      snoozeMinutes: Value(snoozeMinutes),
      vibrate: Value(vibrate),
      enabled: Value(enabled),
      scheduledId: Value(scheduledId),
      updatedAt: Value(DateTime.now()),
      synced: const Value(false),
      deleted: const Value(false),
    );
    await _db.upsertAlarm(companion);

    final saved = (await _db.alarmById(alarmId))!;
    await _reschedule(saved);
    _pushToServer(saved); // fire-and-forget
    return saved;
  }

  Future<void> toggle(Alarm alarm, bool enabled) async {
    await _db.upsertAlarm(
      AlarmsCompanion(
        id: Value(alarm.id),
        enabled: Value(enabled),
        synced: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final saved = (await _db.alarmById(alarm.id))!;
    await _reschedule(saved);
    _pushToServer(saved);
  }

  Future<void> delete(Alarm alarm) async {
    await _alarmService.cancel(alarm.scheduledId);
    await _db.softDeleteAlarm(alarm.id);
    try {
      await _dio.delete('/alarms/${alarm.id}');
      await _db.markAlarmSynced(alarm.id);
    } on DioException {
      /* will reconcile on next sync */
    }
  }

  /// Re-arm every enabled alarm — call on app start and after device reboot.
  Future<void> rescheduleAll() async {
    for (final alarm in await _db.activeAlarms()) {
      await _reschedule(alarm);
    }
  }

  Future<void> _reschedule(Alarm alarm) async {
    // If this alarm is actively ringing right now (e.g. during a cold-start
    // triggered by the user tapping the alarm notification), do NOT cancel
    // it — that would kill the sound.
    if (await _alarmService.isRinging(alarm.scheduledId)) return;

    await _alarmService.cancel(alarm.scheduledId);
    if (!alarm.enabled || alarm.deleted) return;
    final challenge = await _challenges.today();
    await _alarmService.schedule(
      alarm,
      challengeObject: challenge.objectClass,
    );
  }

  Future<void> _pushToServer(Alarm alarm) async {
    try {
      await _dio.post('/alarms', data: alarm.toApiJson());
      await _db.markAlarmSynced(alarm.id);
    } on DioException {
      /* stays unsynced; retried by syncPending */
    }
  }

  /// Push any locally-modified alarms the server hasn't seen yet.
  Future<void> syncPending() async {
    for (final alarm in await _db.unsyncedAlarms()) {
      if (alarm.deleted) {
        try {
          await _dio.delete('/alarms/${alarm.id}');
          await _db.markAlarmSynced(alarm.id);
        } on DioException {/* keep */}
      } else {
        await _pushToServer(alarm);
      }
    }
  }

  /// Pull the signed-in user's alarms from the backend into the local DB.
  /// Restores alarms after a reinstall (local DB is wiped, server is the
  /// source of truth) without clobbering not-yet-synced local edits.
  Future<void> pullFromServer() async {
    List<dynamic> remote;
    try {
      final res = await _dio.get('/alarms');
      remote = res.data as List<dynamic>;
    } on DioException {
      return; // offline — local data stands
    }

    for (final raw in remote) {
      final json = raw as Map<String, dynamic>;
      final id = json['id'] as String;
      final existing = await _db.alarmById(id);
      if (existing != null && !existing.synced) continue; // local edits win

      final time = (json['time'] as String).split(':');
      final repeatDays = (json['repeat_days'] as List).cast<int>();

      await _db.upsertAlarm(AlarmsCompanion(
        id: Value(id),
        label: Value(json['label'] as String),
        hour: Value(int.parse(time[0])),
        minute: Value(int.parse(time[1])),
        repeatDays: Value(repeatDays.join(',')),
        challengeType: Value(json['challenge_type'] as String),
        volume: Value(json['volume'] as int),
        snoozeMinutes: Value(json['snooze_minutes'] as int),
        vibrate: Value(json['vibrate'] as bool),
        enabled: Value(json['enabled'] as bool),
        scheduledId: Value(existing?.scheduledId ?? _scheduledIdFor(id)),
        updatedAt: Value(DateTime.now()),
        synced: const Value(true),
        deleted: const Value(false),
      ));
    }
  }

  /// Deterministic OS-alarm id derived from the server's alarm UUID, so the
  /// same alarm maps to the same scheduled id across reinstalls.
  int _scheduledIdFor(String alarmId) => alarmId.hashCode & 0x7FFFFFFF;
}

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  return AlarmRepository(
    ref.read(appDatabaseProvider),
    ref.read(alarmServiceProvider),
    ref.read(dioProvider),
    ref.read(challengeRepositoryProvider),
  );
});

/// Reactive list of the user's alarms (offline-first).
final alarmsStreamProvider = StreamProvider<List<Alarm>>((ref) {
  return ref.read(alarmRepositoryProvider).watch();
});
