import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/alarm_x.dart';
import '../../data/providers/auth_controller.dart';
import '../../data/repositories/alarm_repository.dart';
import '../../data/repositories/challenge_repository.dart';
import '../../core/storage/app_database.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final alarms = ref.watch(alarmsStreamProvider);
    final challenge = ref.watch(todaysChallengeProvider);
    final auth = ref.watch(authControllerProvider);
    final name = switch (auth) {
      Authenticated(:final user) => user.name.split(' ').first,
      _ => 'there',
    };

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todaysChallengeProvider);
            await ref.read(alarmRepositoryProvider).syncPending();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good morning,',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                      Text(name, style: theme.textTheme.headlineSmall),
                    ],
                  ),
                  IconButton.filledTonal(
                    onPressed: () => context.push(Routes.settings),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              alarms.when(
                loading: () => const _NextAlarmSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
                data: (list) => _NextAlarmCard(alarms: list),
              ),
              const SizedBox(height: 16),
              challenge.when(
                loading: () => const _ChallengeSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
                data: (c) => AppCard(
                  child: Row(
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.center_focus_strong_rounded,
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Today's challenge",
                                style: theme.textTheme.bodySmall),
                            const SizedBox(height: 2),
                            Text('Scan a ${c.displayName}',
                                style: theme.textTheme.titleLarge),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: () => context.push(Routes.createAlarm),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Alarm'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextAlarmCard extends StatelessWidget {
  const _NextAlarmCard({required this.alarms});
  final List<Alarm> alarms;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final enabled = alarms.where((a) => a.enabled).toList();

    if (enabled.isEmpty) {
      return AppCard(
        gradient: const LinearGradient(
          colors: [AppColors.darkCard, AppColors.darkSurface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No alarms set',
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: AppColors.darkText)),
            const SizedBox(height: 6),
            Text('Tap “Add Alarm” to schedule your first wake-up.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.darkTextSecondary)),
          ],
        ),
      );
    }

    enabled.sort((a, b) =>
        a.nextOccurrence(now).compareTo(b.nextOccurrence(now)));
    final next = enabled.first;

    return AppCard(
      gradient: const LinearGradient(
        colors: [AppColors.primary, AppColors.primaryHover],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alarm_rounded,
                  color: AppColors.onPrimary, size: 20),
              const SizedBox(width: 8),
              Text('NEXT ALARM',
                  style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 12),
          Text(next.formattedTime(context),
              style: AppTypography.clock(AppColors.onPrimary)),
          const SizedBox(height: 8),
          Text('${next.repeatLabel}  •  ${next.countdownLabel(now)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.85))),
        ],
      ),
    );
  }
}

class _NextAlarmSkeleton extends StatelessWidget {
  const _NextAlarmSkeleton();
  @override
  Widget build(BuildContext context) =>
      const AppCard(child: SizedBox(height: 110));
}

class _ChallengeSkeleton extends StatelessWidget {
  const _ChallengeSkeleton();
  @override
  Widget build(BuildContext context) =>
      const AppCard(child: SizedBox(height: 56));
}
