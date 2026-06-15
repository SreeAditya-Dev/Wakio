import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../storage/local_prefs.dart';

/// Snapshot of the permissions that decide whether an alarm can ring while the
/// app is backgrounded or killed.
class AlarmPermissions {
  const AlarmPermissions({
    required this.notifications,
    required this.exactAlarm,
    required this.batteryUnrestricted,
  });

  final bool notifications;
  final bool exactAlarm;
  final bool batteryUnrestricted;

  /// The two that make-or-break *background* ringing. Without exact alarms the
  /// OS won't fire the alarm in Doze and — critically on Android 14+ — won't
  /// grant the temporary exemption the ringing foreground service needs to
  /// start from the background. Without notifications the full-screen ring UI
  /// can't be posted.
  bool get backgroundReliable => notifications && exactAlarm;
}

/// Single place to inspect and request the alarm-critical permissions.
class PermissionsService {
  PermissionsService(this._prefs);

  final LocalPrefs _prefs;

  Future<AlarmPermissions> check() async {
    return AlarmPermissions(
      notifications: await Permission.notification.isGranted,
      exactAlarm: await Permission.scheduleExactAlarm.isGranted,
      batteryUnrestricted:
          await Permission.ignoreBatteryOptimizations.isGranted,
    );
  }

  /// Request the permissions an alarm needs to fire from the background. Safe to
  /// call on every cold start: each request no-ops once granted, so there is no
  /// repeated-prompt nagging (which the old every-launch battery prompt caused).
  Future<void> ensureCritical() async {
    // Android 13+: needed to post the ringing notification + full-screen intent.
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }
    // Android 12 only (auto-granted via USE_EXACT_ALARM on 13+). Without it,
    // setExactAndAllowWhileIdle can't arm a Doze-proof alarm, so the alarm only
    // fires once the app/device is woken — exactly the "rings only when I open
    // the app" symptom.
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  /// The battery-optimization exemption prompt — asked at most once
  /// automatically. Re-grant lives in Settings.
  Future<void> requestBatteryExemptionOnce() async {
    if (await _prefs.batteryPromptShown) return;
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
    await _prefs.markBatteryPromptShown();
  }

  Future<void> requestNotifications() => Permission.notification.request();
  Future<void> requestExactAlarm() => Permission.scheduleExactAlarm.request();
  Future<void> requestBatteryExemption() =>
      Permission.ignoreBatteryOptimizations.request();

  /// Opens the app's system settings page (fallback when a permission is
  /// permanently denied and can't be re-requested in-app).
  Future<bool> openSettings() => openAppSettings();
}

final permissionsServiceProvider = Provider<PermissionsService>((ref) {
  return PermissionsService(ref.read(localPrefsProvider));
});
