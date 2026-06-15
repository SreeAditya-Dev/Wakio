import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around platform secure storage for auth tokens.
class TokenStore {
  TokenStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _kAccess, value: access);
    await _storage.write(key: _kRefresh, value: refresh);
  }

  Future<void> saveAccess(String access) =>
      _storage.write(key: _kAccess, value: access);

  Future<String?> get accessToken => _storage.read(key: _kAccess);
  Future<String?> get refreshToken => _storage.read(key: _kRefresh);

  Future<bool> get hasSession async => (await accessToken) != null;

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}

final tokenStoreProvider = Provider<TokenStore>((ref) {
  const options = AndroidOptions(encryptedSharedPreferences: true);
  return TokenStore(const FlutterSecureStorage(aOptions: options));
});
