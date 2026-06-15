import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/services/haptics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../scan/scan_screen.dart';

class RingArgs {
  const RingArgs({
    required this.alarmId,
    required this.scheduledId,
    required this.challengeObject,
    required this.displayName,
    this.historyId,
    this.isRelapse = false,
  });

  final String alarmId;
  final int scheduledId;
  final String challengeObject;
  final String displayName;
  // Set when this ring is a re-fire after a missed "still awake?" check-in.
  final String? historyId;
  final bool isRelapse;
}

/// Full-screen, non-dismissable alarm. The ONLY way out is scanning the object
/// (or the limited snooze). Back / swipe are blocked.
class RingScreen extends ConsumerStatefulWidget {
  const RingScreen({super.key, required this.args});
  final RingArgs? args;

  @override
  ConsumerState<RingScreen> createState() => _RingScreenState();
}

class _RingScreenState extends ConsumerState<RingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);
  Timer? _clockTimer;
  String _now = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Defer the first tick: TimeOfDay.format(context) needs
    // MaterialLocalizations, which isn't available until after initState.
    WidgetsBinding.instance.addPostFrameCallback((_) => _tick());
    _clockTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final n = TimeOfDay.now();
    if (mounted) setState(() => _now = n.format(context));
  }

  @override
  void dispose() {
    _pulse.dispose();
    _clockTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _openCamera() {
    final a = widget.args;
    if (a == null) return;
    ref.read(hapticsProvider).medium();
    context.push(
      Routes.scan,
      extra: ScanArgs(
        alarmId: a.alarmId,
        scheduledId: a.scheduledId,
        challengeObject: a.challengeObject,
        displayName: a.displayName,
        historyId: a.historyId,
        isRelapse: a.isRelapse,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final objectName = args?.displayName ?? 'object';

    // Block all back/swipe dismissal — must scan to escape.
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
                ScaleTransition(
                  scale: Tween(begin: 0.94, end: 1.06).animate(
                    CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                  ),
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        AppColors.primary,
                        AppColors.primaryHover,
                      ]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 50,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.alarm_rounded,
                        size: 60, color: AppColors.onPrimary),
                  ),
                ),
                const SizedBox(height: 36),
                Text(_now, style: AppTypography.clock(Colors.white)),
                const SizedBox(height: 8),
                Text(args?.isRelapse == true ? 'YOU DOZED OFF!' : 'WAKE UP!',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2)),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text('TO STOP, SCAN',
                          style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 8),
                      Text(objectName,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 64,
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openCamera,
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Open Camera',
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
