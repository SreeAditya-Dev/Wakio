import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small persistent key/value store for non-secret app state that must survive
/// restarts: one-time onboarding flags and the cached signed-in user (so the
/// app opens straight into the authenticated UI while offline).
///
/// Backed by the same encrypted store as [TokenStore] to avoid pulling in an
/// extra dependency; the handful of keys here are read once at startup.
class LocalPrefs {
  LocalPrefs(this._storage);

  final FlutterSecureStorage _storage;

  // Set once we've shown the battery-optimization exemption prompt. That prompt
  // is the naggy one (some OEMs never report it as granted), so it's one-shot;
  // the Settings screen offers a manual re-grant. Exact-alarm + notifications
  // are re-checked every launch instead — they no-op once granted.
  static const _kBatteryPromptShown = 'battery_prompt_shown';
  // Last-known signed-in user, as the raw /auth/me JSON string.
  static const _kCachedUser = 'cached_user';
  // Today's resolved challenge (with a 'day' stamp), so it stays stable all day
  // and needs no network on subsequent reads.
  static const _kCachedChallenge = 'cached_challenge';

  Future<bool> get batteryPromptShown async =>
      (await _storage.read(key: _kBatteryPromptShown)) == '1';

  Future<void> markBatteryPromptShown() =>
      _storage.write(key: _kBatteryPromptShown, value: '1');

  Future<void> cacheUser(String json) =>
      _storage.write(key: _kCachedUser, value: json);

  Future<String?> get cachedUser => _storage.read(key: _kCachedUser);

  Future<void> clearUser() => _storage.delete(key: _kCachedUser);

  Future<Map<String, dynamic>?> get cachedChallenge async {
    final raw = await _storage.read(key: _kCachedChallenge);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheChallenge(Map<String, dynamic> json) =>
      _storage.write(key: _kCachedChallenge, value: jsonEncode(json));
}

final localPrefsProvider = Provider<LocalPrefs>((ref) {
  const options = AndroidOptions(encryptedSharedPreferences: true);
  return LocalPrefs(const FlutterSecureStorage(aOptions: options));
});
