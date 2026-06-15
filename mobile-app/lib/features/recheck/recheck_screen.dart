import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/services/alarm_service.dart';
import '../../core/services/haptics_service.dart';
import '../../core/storage/app_database.dart';
import '../../core/theme/app_colors.dart';

class RecheckArgs {
  const RecheckArgs({
    required this.alarmId,
    required this.historyId,
    required this.scheduledId,
    required this.challengeObject,
  });

  final String alarmId;
  final String historyId;
  final int scheduledId;
  final String challengeObject;
}

/// Gentle post-wake "are you still up?" check-in. Fires 5–15 min after a
/// successful scan. Tapping "I'm up!" within [_window] marks the wake as
/// verified; letting it time out re-arms the loud alarm via [RingScreen].
class RecheckScreen extends ConsumerStatefulWidget {
  const RecheckScreen({super.key, required this.args});
  final RecheckArgs args;

  @override
  ConsumerState<RecheckScreen> createState() => _RecheckScreenState();
}

class _RecheckScreenState extends ConsumerState<RecheckScreen> {
  static const _window = Duration(seconds: 30);
  late final DateTime _deadline = DateTime.now().add(_window);
  Timer? _ticker;
  Duration _remaining = _window;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final remaining = _deadline.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _onTimeout();
      return;
    }
    if (mounted) setState(() => _remaining = remaining);
  }

  Future<void> _confirmAwake() async {
    if (_handled) return;
    _handled = true;
    _ticker?.cancel();
    await ref.read(hapticsProvider).success();
    await ref.read(alarmServiceProvider).cancel(widget.args.scheduledId);
    await ref
        .read(appDatabaseProvider)
        .updateRecheckStatus(widget.args.historyId, 'verified');
    if (mounted) context.go(Routes.home);
  }

  Future<void> _onTimeout() async {
    if (_handled) return;
    _handled = true;
    _ticker?.cancel();
    final alarmService = ref.read(alarmServiceProvider);
    await alarmService.cancel(widget.args.scheduledId);
    final alarm =
        await ref.read(appDatabaseProvider).alarmById(widget.args.alarmId);
    if (alarm != null) {
      await alarmService.scheduleRelapse(
        alarm,
        historyId: widget.args.historyId,
        challengeObject: widget.args.challengeObject,
      );
    }
    // The relapse alarm fires within a second and the app-wide ringing
    // listener takes over from there — nothing else to do on this screen.
  }

  @override
  void dispose() {
    _ticker?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bedtime_rounded,
                      size: 56, color: AppColors.primary),
                ),
                const SizedBox(height: 32),
                Text('Still awake?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Text(
                  "Tap below to confirm you're up. If you don't, the alarm "
                  'rings again and your streak takes a hit.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.darkTextSecondary),
                ),
                const SizedBox(height: 28),
                Text('${_remaining.inSeconds}s',
                    style: theme.textTheme.displayMedium?.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w800)),
                const Spacer(),
                SizedBox(
                  height: 64,
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _confirmAwake,
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text("I'm up!",
                        style: TextStyle(fontSize: 18)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
