import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/services/haptics_service.dart';
import '../../core/storage/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/alarm_x.dart';
import '../../data/repositories/alarm_repository.dart';

class AlarmListScreen extends ConsumerWidget {
  const AlarmListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(alarmsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Alarms')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        onPressed: () => context.push(Routes.createAlarm),
        child: const Icon(Icons.add_rounded),
      ),
      body: alarms.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) return const _EmptyAlarms();
          final sorted = [...list]..sort((a, b) =>
              (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _AlarmTile(alarm: sorted[i]),
          );
        },
      ),
    );
  }
}

class _AlarmTile extends ConsumerWidget {
  const _AlarmTile({required this.alarm});
  final Alarm alarm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey(alarm.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(hapticsProvider).medium();
        ref.read(alarmRepositoryProvider).delete(alarm);
      },
      child: AppCard(
        onTap: () =>
            context.push('${Routes.createAlarm}?id=${alarm.id}'),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alarm.formattedTime(context),
                      style: theme.textTheme.displaySmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(alarm.repeatLabel, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.center_focus_strong_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text('Scan challenge',
                          style: theme.textTheme.labelMedium
                              ?.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: alarm.enabled,
              onChanged: (v) {
                ref.read(hapticsProvider).selection();
                ref.read(alarmRepositoryProvider).toggle(alarm, v);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAlarms extends StatelessWidget {
  const _EmptyAlarms();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.alarm_off_rounded,
                size: 72, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 20),
            Text('No alarms yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Add one and we\'ll make sure you\'re fully awake.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
