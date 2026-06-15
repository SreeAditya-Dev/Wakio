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
      notifications: await _isGranted(Permission.notification),
      exactAlarm: await _isGranted(Permission.scheduleExactAlarm),
      batteryUnrestricted:
          await _isGranted(Permission.ignoreBatteryOptimizations),
    );
  }

  /// Some permissions (notably battery optimization) can throw on devices /
  /// emulators that don't expose them. Treat any failure as "not granted"
  /// rather than letting it crash the caller.
  Future<bool> _isGranted(Permission p) async {
    try {
      return await p.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Request the permissions an alarm needs to fire from the background. Safe to
  /// call on every cold start: each request no-ops once granted, so there is no
  /// repeated-prompt nagging (which the old every-launch battery prompt caused).
  Future<void> ensureCritical() async {
    // Android 13+: needed to post the ringing notification + full-screen intent.
    if (!await _isGranted(Permission.notification)) {
      await _request(Permission.notification);
    }
    // Android 12 only (auto-granted via USE_EXACT_ALARM on 13+). Without it,
    // setExactAndAllowWhileIdle can't arm a Doze-proof alarm, so the alarm only
    // fires once the app/device is woken — exactly the "rings only when I open
    // the app" symptom.
    if (!await _isGranted(Permission.scheduleExactAlarm)) {
      await _request(Permission.scheduleExactAlarm);
    }
  }

  /// The battery-optimization exemption prompt — asked at most once
  /// automatically. Re-grant lives in Settings.
  Future<void> requestBatteryExemptionOnce() async {
    if (await _prefs.batteryPromptShown) return;
    if (!await _isGranted(Permission.ignoreBatteryOptimizations)) {
      await _request(Permission.ignoreBatteryOptimizations);
    }
    await _prefs.markBatteryPromptShown();
  }

  Future<bool> requestNotifications() =>
      _request(Permission.notification);
  Future<bool> requestExactAlarm() =>
      _request(Permission.scheduleExactAlarm);
  Future<bool> requestBatteryExemption() =>
      _request(Permission.ignoreBatteryOptimizations);

  /// Requests [p] and reports whether it ended up granted. Never throws — on a
  /// platform error (e.g. no settings activity for battery optimization) it
  /// returns false so the UI can fall back to [openSettings].
  Future<bool> _request(Permission p) async {
    try {
      final status = await p.request();
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Opens the app's system settings page (fallback when a permission is
  /// permanently denied or can't be requested in-app).
  Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } catch (_) {
      return false;
    }
  }
}

final permissionsServiceProvider = Provider<PermissionsService>((ref) {
  return PermissionsService(ref.read(localPrefsProvider));
});
