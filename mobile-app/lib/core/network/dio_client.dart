import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env/app_env.dart';
import '../storage/secure_storage.dart';

/// Authenticated Dio instance with automatic JWT attach + 401→refresh→retry.
final dioProvider = Provider<Dio>((ref) {
  final tokenStore = ref.read(tokenStoreProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppEnv.apiBaseUrl,
      // Kept modest so offline calls fail fast — important for the scan loop,
      // which needs to detect an unreachable server quickly to fall back.
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(_AuthInterceptor(dio, tokenStore));
  return dio;
});

class _AuthInterceptor extends QueuedInterceptor {
  _AuthInterceptor(this._dio, this._tokens);

  final Dio _dio;
  final TokenStore _tokens;
  bool _refreshing = false;

  bool _isAuthPath(String path) =>
      path.contains('/auth/login') ||
      path.contains('/auth/signup') ||
      path.contains('/auth/refresh') ||
      path.contains('/auth/google');

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_isAuthPath(options.path)) {
      final token = await _tokens.accessToken;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;

    if (status != 401 || _isAuthPath(path) || _refreshing) {
      return handler.next(err);
    }

    final refresh = await _tokens.refreshToken;
    if (refresh == null) return handler.next(err);

    try {
      _refreshing = true;
      final res = await _dio.post('/auth/refresh',
          data: {'refresh_token': refresh});
      final newAccess = res.data['access_token'] as String;
      final newRefresh = res.data['refresh_token'] as String?;
      await _tokens.save(
        access: newAccess,
        refresh: newRefresh ?? refresh,
      );

      // Retry the original request with the fresh token.
      final req = err.requestOptions;
      req.headers['Authorization'] = 'Bearer $newAccess';
      final retried = await _dio.fetch(req);
      return handler.resolve(retried);
    } on DioException {
      await _tokens.clear();
      return handler.next(err);
    } finally {
      _refreshing = false;
    }
  }
}
