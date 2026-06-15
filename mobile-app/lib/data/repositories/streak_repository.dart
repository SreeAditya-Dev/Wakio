import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/app_database.dart';

/// Derives the wake streak + totals from completed local history rows so the
/// stats work fully offline. The server keeps an authoritative copy too.
class StreakRepository {
  StreakRepository(this._db);
  final AppDatabase _db;

  Future<StreakSummary> summary() async {
    final rows = await _db.watchHistory().first;
    final completed = rows.where((h) => h.completed).toList();
    final totalPoints =
        completed.fold<int>(0, (sum, h) => sum + h.points);

    final days = completed
        .map((h) => DateTime(h.firedAt.year, h.firedAt.month, h.firedAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    var streak = 0;
    var cursor = _todayDate();
    // Allow the streak to count whether or not today is already done.
    if (days.isNotEmpty && days.first.isBefore(cursor)) {
      cursor = days.first;
    }
    for (final d in days) {
      if (d == cursor) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (d.isBefore(cursor)) {
        break;
      }
    }

    final successRate = rows.isEmpty
        ? 0.0
        : completed.length / rows.length;

    return StreakSummary(
      currentStreak: streak,
      totalPoints: totalPoints,
      successRate: successRate,
      completedCount: completed.length,
    );
  }

  Future<int> recordCompletion(
      {required int points, required DateTime day}) async {
    // History row is inserted by the caller; just recompute.
    return (await summary()).currentStreak;
  }

  DateTime _todayDate() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }
}

class StreakSummary {
  const StreakSummary({
    required this.currentStreak,
    required this.totalPoints,
    required this.successRate,
    required this.completedCount,
  });
  final int currentStreak;
  final int totalPoints;
  final double successRate;
  final int completedCount;
}

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository(ref.read(appDatabaseProvider));
});

final streakSummaryProvider = FutureProvider<StreakSummary>((ref) {
  return ref.read(streakRepositoryProvider).summary();
});
