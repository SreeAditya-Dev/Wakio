import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../core/storage/local_prefs.dart';
import '../../core/storage/secure_storage.dart';
import '../models/user.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository(this._dio, this._tokens, this._prefs);

  final Dio _dio;
  final TokenStore _tokens;
  final LocalPrefs _prefs;

  Future<AppUser> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _call('/auth/signup', {
      'name': name,
      'email': email,
      'password': password,
      'accepted_terms': true,
    });
    return _handleAuth(res);
  }

  Future<AppUser> login(String email, String password) async {
    final res = await _call('/auth/login', {
      'email': email,
      'password': password,
    });
    return _handleAuth(res);
  }

  Future<AppUser> loginWithGoogle(String idToken) async {
    final res = await _call('/auth/google', {'id_token': idToken});
    return _handleAuth(res);
  }

  /// Offline-first session restore.
  ///
  /// If we hold a session token AND a cached user, return it immediately so the
  /// app opens straight into the authenticated UI — even with no internet — and
  /// revalidate with the backend in the background. Only an *explicit* server
  /// rejection (401) logs the user out; transient/offline errors keep the
  /// session so a flaky connection never bounces the user to the login screen.
  Future<AppUser?> currentUser() async {
    if (!await _tokens.hasSession) return null;

    final cached = await _prefs.cachedUser;
    if (cached != null) {
      unawaited(_fetchMe()); // background refresh; ignore result
      return AppUser.fromJson(jsonDecode(cached) as Map<String, dynamic>);
    }
    // No cache yet (first launch after login on a fresh install): must hit the
    // network. Returns null when offline -> user lands on login this once.
    return _fetchMe();
  }

  /// Hits /auth/me, refreshes the local cache, and surfaces a real logout only
  /// on a 401. Returns null (without clearing the session) when offline.
  Future<AppUser?> _fetchMe() async {
    try {
      final res = await _dio.get('/auth/me');
      final data = res.data as Map<String, dynamic>;
      await _prefs.cacheUser(jsonEncode(data));
      return AppUser.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _clearSession();
      }
      return null;
    }
  }

  Future<void> logout() => _clearSession();

  Future<void> _clearSession() async {
    await _tokens.clear();
    await _prefs.clearUser();
  }

  Future<Response> _call(String path, Map<String, dynamic> body) async {
    try {
      return await _dio.post(path, data: body);
    } on DioException catch (e) {
      throw AuthException(_message(e));
    }
  }

  Future<AppUser> _handleAuth(Response res) async {
    final data = res.data as Map<String, dynamic>;
    final tokens = data['tokens'] as Map<String, dynamic>;
    await _tokens.save(
      access: tokens['access_token'] as String,
      refresh: tokens['refresh_token'] as String,
    );
    final userJson = data['user'] as Map<String, dynamic>;
    await _prefs.cacheUser(jsonEncode(userJson)); // for offline restore
    return AppUser.fromJson(userJson);
  }

  String _message(DioException e) {
    final detail = e.response?.data;
    if (detail is Map && detail['detail'] is String) return detail['detail'];
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Cannot reach the server. Check your connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(dioProvider),
    ref.read(tokenStoreProvider),
    ref.read(localPrefsProvider),
  );
});
