import 'dart:convert';
import 'dart:math';

import 'package:alarm/alarm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/app_database.dart' as db;
import '../../data/models/alarm_x.dart';

/// Payload carried with each scheduled OS alarm so the ring screen knows which
/// app alarm fired and which object to scan.
///
/// [type] distinguishes the three kinds of OS alarm this app schedules:
///  - 'main': the user's scheduled alarm — must scan to dismiss.
///  - 'recheck': a gentle post-wake "are you still up?" check-in.
///  - 'relapse': the loud re-ring fired when a recheck is missed.
class AlarmPayload {
  AlarmPayload({
    this.type = 'main',
    required this.alarmId,
    required this.challengeObject,
    this.historyId,
  });
  final String type;
  final String alarmId;
  final String challengeObject;
  final String? historyId;

  String encode() => jsonEncode({
        'type': type,
        'alarmId': alarmId,
        'challenge': challengeObject,
        if (historyId != null) 'historyId': historyId,
      });

  static AlarmPayload? tryDecode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return AlarmPayload(
        type: m['type'] as String? ?? 'main',
        alarmId: m['alarmId'] as String? ?? '',
        challengeObject: m['challenge'] as String? ?? 'chair',
        historyId: m['historyId'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

/// A currently-ringing alarm with everything the ring/scan/recheck flow needs.
class RingingAlarm {
  RingingAlarm({
    required this.scheduledId,
    required this.type,
    required this.alarmId,
    required this.challengeObject,
    this.historyId,
  });
  final int scheduledId;
  final String type;
  final String alarmId;
  final String challengeObject;
  final String? historyId;
}

/// Wraps the `alarm` package. Configured so the alarm:
///  - rings on STREAM_ALARM/USAGE_ALARM (ignores silent + DND by default),
///  - forces volume to max and enforces it (cannot be lowered),
///  - shows a full-screen intent over the lockscreen,
///  - keeps ringing if the app is killed and reschedules after reboot.
class AlarmService {
  // null -> device's default alarm sound. Drop an mp3 in assets/audio/ and set
  // this (plus the pubspec asset entry) to bundle a custom default tone.
  static const String? _defaultSound = null;

  Future<void> init() => Alarm.init();

  /// Stream of currently-ringing alarms, pairing the OS alarm id with the
  /// decoded payload so the UI can both render and later cancel it.
  Stream<List<RingingAlarm>> get ringingStream => Alarm.ringing.map(
        (set) => set.alarms
            .map((a) {
              final p = AlarmPayload.tryDecode(a.payload);
              return p == null
                  ? null
                  : RingingAlarm(
                      scheduledId: a.id,
                      type: p.type,
                      alarmId: p.alarmId,
                      challengeObject: p.challengeObject,
                      historyId: p.historyId,
                    );
            })
            .whereType<RingingAlarm>()
            .toList(),
      );

  Future<void> schedule(
    db.Alarm alarm, {
    required String challengeObject,
    DateTime? from,
  }) async {
    if (!alarm.enabled || alarm.deleted) return;
    final when = alarm.nextOccurrence(from ?? DateTime.now());

    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: alarm.scheduledId,
        dateTime: when,
        // alarm.soundPath is a path relative to the app Documents dir,
        // written by the sound picker. Falls back to the device default.
        assetAudioPath: alarm.soundPath ?? _defaultSound,
        loopAudio: true,
        vibrate: alarm.vibrate,
        // Full volume, enforced — overrides low/silent system volume.
        volumeSettings: VolumeSettings.fixed(
          volume: (alarm.volume / 100).clamp(0.0, 1.0),
          volumeEnforced: true,
        ),
        androidFullScreenIntent: true,
        // Off on Android: alarms are armed via AlarmManager and survive the app
        // being swiped away, so the package's "your alarms may not ring" notice
        // would fire every time the app is closed and just confuse the user.
        warningNotificationOnKill: false,
        androidStopAlarmOnTermination: false,
        notificationSettings: NotificationSettings(
          title: alarm.label,
          body: 'Scan a ${_titleCase(challengeObject)} to turn it off',
          // Defaults to the app icon. Add res/drawable/notification_icon.png
          // (monochrome, 24dp) and set `icon: 'notification_icon'` to customize.
        ),
        payload: AlarmPayload(
          type: 'main',
          alarmId: alarm.id,
          challengeObject: challengeObject,
        ).encode(),
      ),
    );
  }

  /// Schedules a gentle "are you still up?" check-in 5–15 minutes after a
  /// successful wake. If it's not acknowledged in time, [scheduleRelapse]
  /// re-arms the loud alarm so falling back asleep doesn't go unnoticed.
  Future<void> scheduleRecheck({
    required String alarmId,
    required String historyId,
    required String challengeObject,
  }) async {
    final delay = _recheckDelayMin +
        Duration(
          minutes: Random().nextInt(
            _recheckDelayMax.inMinutes - _recheckDelayMin.inMinutes + 1,
          ),
        );

    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: recheckIdFor(historyId),
        dateTime: DateTime.now().add(delay),
        assetAudioPath: _defaultSound,
        loopAudio: true,
        vibrate: true,
        volumeSettings: const VolumeSettings.fixed(volume: 0.4),
        androidFullScreenIntent: true,
        // Off on Android: alarms are armed via AlarmManager and survive the app
        // being swiped away, so the package's "your alarms may not ring" notice
        // would fire every time the app is closed and just confuse the user.
        warningNotificationOnKill: false,
        androidStopAlarmOnTermination: false,
        notificationSettings: const NotificationSettings(
          title: 'Still awake?',
          body: "Confirm you're up — or the alarm rings again.",
        ),
        payload: AlarmPayload(
          type: 'recheck',
          alarmId: alarmId,
          challengeObject: challengeObject,
          historyId: historyId,
        ).encode(),
      ),
    );
  }

  /// Re-arms the full-volume scan-to-stop alarm after a missed check-in.
  Future<void> scheduleRelapse(
    db.Alarm alarm, {
    required String historyId,
    required String challengeObject,
  }) async {
    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: relapseIdFor(historyId),
        dateTime: DateTime.now().add(const Duration(seconds: 1)),
        assetAudioPath: alarm.soundPath ?? _defaultSound,
        loopAudio: true,
        vibrate: alarm.vibrate,
        volumeSettings: VolumeSettings.fixed(
          volume: (alarm.volume / 100).clamp(0.0, 1.0),
          volumeEnforced: true,
        ),
        androidFullScreenIntent: true,
        // Off on Android: alarms are armed via AlarmManager and survive the app
        // being swiped away, so the package's "your alarms may not ring" notice
        // would fire every time the app is closed and just confuse the user.
        warningNotificationOnKill: false,
        androidStopAlarmOnTermination: false,
        notificationSettings: NotificationSettings(
          title: alarm.label,
          body: 'You dozed off — scan a ${_titleCase(challengeObject)} again!',
        ),
        payload: AlarmPayload(
          type: 'relapse',
          alarmId: alarm.id,
          challengeObject: challengeObject,
          historyId: historyId,
        ).encode(),
      ),
    );
  }

  /// Fires a one-off diagnostic alarm [delay] from now (default 10s) so the
  /// user can lock/close the app and confirm it rings from the background.
  /// Non-looping, so it stops on its own after the tone plays — and carries a
  /// 'test' payload the app uses to skip the scan screen.
  static const int testAlarmId = 990001;

  Future<void> scheduleTest({Duration delay = const Duration(seconds: 10)}) async {
    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: testAlarmId,
        dateTime: DateTime.now().add(delay),
        assetAudioPath: _defaultSound,
        loopAudio: false,
        vibrate: true,
        volumeSettings: const VolumeSettings.fixed(
          volume: 0.8,
          volumeEnforced: true,
        ),
        androidFullScreenIntent: true,
        // Off on Android: alarms are armed via AlarmManager and survive the app
        // being swiped away, so the package's "your alarms may not ring" notice
        // would fire every time the app is closed and just confuse the user.
        warningNotificationOnKill: false,
        androidStopAlarmOnTermination: false,
        notificationSettings: const NotificationSettings(
          title: 'Wakio test alarm',
          body: 'If you hear this with the app closed, background alarms work.',
        ),
        payload: AlarmPayload(
          type: 'test',
          alarmId: 'test',
          challengeObject: 'chair',
        ).encode(),
      ),
    );
  }

  Future<void> cancelRecheck(String historyId) =>
      Alarm.stop(recheckIdFor(historyId));

  /// Deterministic OS-alarm ids for the recheck/relapse pair, derived from
  /// the history row id so they can be cancelled without extra bookkeeping.
  int recheckIdFor(String historyId) => _derivedId(historyId, 1);
  int relapseIdFor(String historyId) => _derivedId(historyId, 2);

  int _derivedId(String historyId, int salt) =>
      Object.hash(historyId, salt) & 0x7FFFFFFF;

  static const _recheckDelayMin = Duration(minutes: 5);
  static const _recheckDelayMax = Duration(minutes: 15);

  Future<void> cancel(int scheduledId) => Alarm.stop(scheduledId);

  Future<bool> isRinging(int scheduledId) => Alarm.isRinging(scheduledId);

  String _titleCase(String s) => s
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

final alarmServiceProvider = Provider<AlarmService>((ref) => AlarmService());
