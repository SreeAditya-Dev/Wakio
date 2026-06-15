import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../models/challenge.dart';

/// Fetches today's scan object. Offline-first: falls back to a deterministic
/// local pick so the alarm can still ring + be dismissed without network.
class ChallengeRepository {
  ChallengeRepository(this._dio);
  final Dio _dio;

  Future<Challenge> today() async {
    try {
      final res = await _dio.get('/challenges/today');
      return Challenge.fromJson(res.data as Map<String, dynamic>);
    } on DioException {
      // Server unreachable — pick a random household object so the user
      // isn't always stuck scanning the same thing.
      return Challenge.random();
    }
  }
}

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository(ref.read(dioProvider));
});

final todaysChallengeProvider = FutureProvider<Challenge>((ref) async {
  return ref.read(challengeRepositoryProvider).today();
});
