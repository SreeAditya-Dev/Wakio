import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/storage/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/glass.dart';
import '../../data/repositories/streak_repository.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = ref.watch(streakSummaryProvider);
    final history = ref.watch(historyStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: AmbientGlow(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(streakSummaryProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 108),
          children: [
            summary.when(
              loading: () => const AppCard(child: SizedBox(height: 90)),
              error: (_, __) => const SizedBox.shrink(),
              data: (s) => Row(
                children: [
                  Expanded(
                    child: _Metric(
                      icon: Icons.local_fire_department_rounded,
                      value: '${s.currentStreak}',
                      label: 'Day streak',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Metric(
                      icon: Icons.check_circle_rounded,
                      value: '${(s.successRate * 100).round()}%',
                      label: 'Success rate',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Metric(
                      icon: Icons.bolt_rounded,
                      value: '${s.totalPoints}',
                      label: 'Points',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('History', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            history.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (rows) {
                if (rows.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('No wake-ups recorded yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final h in rows) ...[
                      _HistoryRow(item: h),
                      const SizedBox(height: 10),
                    ]
                  ],
                );
              },
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(
      {required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(value,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          Text(label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item});
  final HistoryData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('d MMM • h:mm a');
    final relapsed = item.recheckStatus == 'relapsed';
    // Cheap glass (no per-row BackdropFilter) — keeps a long history list smooth.
    return GlassCard(
      blur: false,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            item.completed
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: item.completed ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(df.format(item.firedAt),
                    style: theme.textTheme.titleSmall),
                if (item.challengeObject != null)
                  Text('Scanned: ${item.challengeObject}',
                      style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (item.completed) _RecheckChip(status: item.recheckStatus),
          const SizedBox(width: 10),
          if (item.points > 0)
            Text(relapsed ? '+0' : '+${item.points}',
                style: theme.textTheme.labelLarge?.copyWith(
                    color:
                        relapsed ? AppColors.warning : AppColors.primary)),
        ],
      ),
    );
  }
}

/// Small status pill showing the outcome of the post-wake check-in.
class _RecheckChip extends StatelessWidget {
  const _RecheckChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (status) {
      'verified' => (Icons.verified_rounded, 'Verified', AppColors.success),
      'relapsed' => (Icons.bedtime_rounded, 'Dozed off', AppColors.warning),
      _ => (Icons.hourglass_top_rounded, 'Checking…', AppColors.warning),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: color)),
        ],
      ),
    );
  }
}

final historyStreamProvider = StreamProvider<List<HistoryData>>((ref) {
  return ref.read(appDatabaseProvider).watchHistory();
});
