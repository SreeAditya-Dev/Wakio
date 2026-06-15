import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../../core/storage/local_prefs.dart';
import '../models/challenge.dart';

/// Resolves today's scan-to-stop object. Offline-first and *stable*: once
/// resolved for a given day it's cached, so the home screen, the scheduled
/// alarm payload, and the ring screen always agree — and after the first
/// resolve it needs no network at all.
class ChallengeRepository {
  ChallengeRepository(this._dio, this._prefs);

  final Dio _dio;
  final LocalPrefs _prefs;

  Future<Challenge> today() async {
    final dayKey = _dayKey(DateTime.now());

    // 1. Already resolved today? Use it — no network.
    final cached = await _prefs.cachedChallenge;
    if (cached != null && cached['day'] == dayKey) {
      return Challenge.fromJson(cached);
    }

    // 2. Try the server (authoritative pick), and cache it for the day.
    try {
      final res = await _dio.get('/challenges/today');
      final json = res.data as Map<String, dynamic>;
      await _cache(json, dayKey);
      return Challenge.fromJson(json);
    } on DioException {
      // 3. Offline: deterministic per-day object, cached so it stays put today.
      final challenge = Challenge.offlineFor(DateTime.now());
      await _cache(challenge.toJson(), dayKey);
      return challenge;
    }
  }

  Future<void> _cache(Map<String, dynamic> json, String dayKey) =>
      _prefs.cacheChallenge({...json, 'day': dayKey});

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository(
    ref.read(dioProvider),
    ref.read(localPrefsProvider),
  );
});

final todaysChallengeProvider = FutureProvider<Challenge>((ref) async {
  return ref.read(challengeRepositoryProvider).today();
});
