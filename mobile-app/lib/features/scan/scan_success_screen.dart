import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/dio_client.dart';
import '../../core/router/app_router.dart';
import '../../core/storage/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../data/repositories/streak_repository.dart';

class ScanSuccessArgs {
  const ScanSuccessArgs({
    required this.alarmId,
    required this.challengeObject,
    required this.displayName,
  });
  final String alarmId;
  final String challengeObject;
  final String displayName;
}

class ScanSuccessScreen extends ConsumerStatefulWidget {
  const ScanSuccessScreen({super.key, required this.args});
  final ScanSuccessArgs args;

  @override
  ConsumerState<ScanSuccessScreen> createState() => _State();
}

class _State extends ConsumerState<ScanSuccessScreen> {
  static const _points = 10;
  int _streak = 0;
  bool _recorded = false;

  @override
  void initState() {
    super.initState();
    _record();
  }

  Future<void> _record() async {
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();

    // Local history (offline-first).
    await db.insertHistory(
      HistoryCompanion.insert(
        id: const Uuid().v4(),
        alarmId: Value(widget.args.alarmId),
        firedAt: now,
        challengeObject: Value(widget.args.challengeObject),
        completed: const Value(true),
        wakeTime: Value(now),
        points: const Value(_points),
      ),
    );

    final streak = await ref.read(streakRepositoryProvider).recordCompletion(
          points: _points,
          day: now,
        );

    // Best-effort server sync.
    try {
      await ref.read(dioProvider).post('/alarm-history', data: {
        'alarm_id': widget.args.alarmId,
        'fired_at': now.toIso8601String(),
        'challenge_object': widget.args.challengeObject,
        'completed': true,
        'wake_time': now.toIso8601String(),
        'points': _points,
      });
    } catch (_) {/* endpoint may not exist yet; local record stands */}

    if (mounted) {
      setState(() {
        _streak = streak;
        _recorded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 550),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: Container(
                    height: 130,
                    width: 130,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 80, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Text('Great job!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Alarm stopped. You\'re awake!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _StatPill(
                      icon: Icons.bolt_rounded,
                      value: '+$_points',
                      label: 'Wake points',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _StatPill(
                      icon: Icons.local_fire_department_rounded,
                      value: _recorded ? '$_streak' : '…',
                      label: 'Day streak',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              AppButton(
                label: 'Done',
                onPressed: () => context.go(Routes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill(
      {required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
