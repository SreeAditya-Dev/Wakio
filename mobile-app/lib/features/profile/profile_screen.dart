import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../data/providers/auth_controller.dart';
import '../../data/repositories/streak_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authControllerProvider);
    final summary = ref.watch(streakSummaryProvider);

    final user = switch (auth) {
      Authenticated(:final user) => user,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => context.push(Routes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  backgroundImage: user?.avatarUrl != null
                      ? NetworkImage(user!.avatarUrl!)
                      : null,
                  child: user?.avatarUrl == null
                      ? Text(
                          (user?.name.isNotEmpty ?? false)
                              ? user!.name[0].toUpperCase()
                              : '?',
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(color: AppColors.primary),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(user?.name ?? 'Guest',
                    style: theme.textTheme.headlineSmall),
                Text(user?.email ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                if (user?.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Joined ${DateFormat.yMMMM().format(user!.createdAt!)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          summary.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (s) => AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Mini(value: '${s.currentStreak}', label: 'Streak 🔥'),
                  _Mini(value: '${s.totalPoints}', label: 'Points'),
                  _Mini(
                      value: '${(s.successRate * 100).round()}%',
                      label: 'Success'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            tileColor: theme.colorScheme.surfaceContainerHighest,
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text('Log out'),
            onTap: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
