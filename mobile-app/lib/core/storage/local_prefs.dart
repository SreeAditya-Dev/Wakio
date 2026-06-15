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

  // Set once after we've asked for exact-alarm + battery-optimization
  // exemptions, so we never nag the user on every cold start.
  static const _kPermsOnboarded = 'perms_onboarded';
  // Last-known signed-in user, as the raw /auth/me JSON string.
  static const _kCachedUser = 'cached_user';

  Future<bool> get permissionsOnboarded async =>
      (await _storage.read(key: _kPermsOnboarded)) == '1';

  Future<void> markPermissionsOnboarded() =>
      _storage.write(key: _kPermsOnboarded, value: '1');

  Future<void> cacheUser(String json) =>
      _storage.write(key: _kCachedUser, value: json);

  Future<String?> get cachedUser => _storage.read(key: _kCachedUser);

  Future<void> clearUser() => _storage.delete(key: _kCachedUser);
}

final localPrefsProvider = Provider<LocalPrefs>((ref) {
  const options = AndroidOptions(encryptedSharedPreferences: true);
  return LocalPrefs(const FlutterSecureStorage(aOptions: options));
});
