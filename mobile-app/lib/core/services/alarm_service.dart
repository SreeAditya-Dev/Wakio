import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/app_database.dart' as db;
import '../../data/models/alarm_x.dart';

/// Payload carried with each scheduled OS alarm so the ring screen knows which
/// app alarm fired and which object to scan.
class AlarmPayload {
  AlarmPayload({required this.alarmId, required this.challengeObject});
  final String alarmId;
  final String challengeObject;

  String encode() =>
      jsonEncode({'alarmId': alarmId, 'challenge': challengeObject});

  static AlarmPayload? tryDecode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return AlarmPayload(
        alarmId: m['alarmId'] as String? ?? '',
        challengeObject: m['challenge'] as String? ?? 'chair',
      );
    } catch (_) {
      return null;
    }
  }
}

/// A currently-ringing alarm with everything the ring/scan flow needs.
class RingingAlarm {
  RingingAlarm({
    required this.scheduledId,
    required this.alarmId,
    required this.challengeObject,
  });
  final int scheduledId;
  final String alarmId;
  final String challengeObject;
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
                      alarmId: p.alarmId,
                      challengeObject: p.challengeObject,
                    );
            })
            .whereType<RingingAlarm>()
            .toList(),
      );

  Future<void> schedule(
    db.Alarm alarm, {
    required String challengeObject,
    String? assetAudioPath,
    DateTime? from,
  }) async {
    if (!alarm.enabled || alarm.deleted) return;
    final when = alarm.nextOccurrence(from ?? DateTime.now());

    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: alarm.scheduledId,
        dateTime: when,
        assetAudioPath: assetAudioPath ?? _defaultSound,
        loopAudio: true,
        vibrate: alarm.vibrate,
        // Full volume, enforced — overrides low/silent system volume.
        volumeSettings: VolumeSettings.fixed(
          volume: (alarm.volume / 100).clamp(0.0, 1.0),
          volumeEnforced: true,
        ),
        androidFullScreenIntent: true,
        warningNotificationOnKill: true,
        androidStopAlarmOnTermination: false,
        notificationSettings: NotificationSettings(
          title: alarm.label,
          body: 'Scan a ${_titleCase(challengeObject)} to turn it off',
          // Defaults to the app icon. Add res/drawable/notification_icon.png
          // (monochrome, 24dp) and set `icon: 'notification_icon'` to customize.
        ),
        payload: AlarmPayload(
          alarmId: alarm.id,
          challengeObject: challengeObject,
        ).encode(),
      ),
    );
  }

  Future<void> cancel(int scheduledId) => Alarm.stop(scheduledId);

  Future<bool> isRinging(int scheduledId) => Alarm.isRinging(scheduledId);

  String _titleCase(String s) => s
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

final alarmServiceProvider = Provider<AlarmService>((ref) => AlarmService());
