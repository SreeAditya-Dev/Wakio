import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import '../models/user.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository(this._dio, this._tokens);

  final Dio _dio;
  final TokenStore _tokens;

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

  Future<AppUser?> currentUser() async {
    if (!await _tokens.hasSession) return null;
    try {
      final res = await _dio.get('/auth/me');
      return AppUser.fromJson(res.data as Map<String, dynamic>);
    } on DioException {
      return null;
    }
  }

  Future<void> logout() => _tokens.clear();

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
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
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
  return AuthRepository(ref.read(dioProvider), ref.read(tokenStoreProvider));
});
