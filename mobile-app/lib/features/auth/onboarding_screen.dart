import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnbData(
      icon: Icons.alarm_on_rounded,
      title: 'Alarms that won\'t quit',
      body:
          'Full volume even in silent or Do Not Disturb mode — so you never sleep through it.',
    ),
    _OnbData(
      icon: Icons.center_focus_strong_rounded,
      title: 'Scan to stop',
      body:
          'To turn the alarm off you must physically scan a random object — a chair, a bottle, your toothbrush.',
    ),
    _OnbData(
      icon: Icons.local_fire_department_rounded,
      title: 'Build a wake streak',
      body:
          'A fresh object every morning keeps you alert. Earn points and grow your streak.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go(Routes.signup),
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _OnbView(data: _pages[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: i == _page ? 24 : 8,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: AppButton(
                label: isLast ? 'Get started' : 'Next',
                onPressed: () {
                  if (isLast) {
                    context.go(Routes.signup);
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnbData {
  const _OnbData({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
}

class _OnbView extends StatelessWidget {
  const _OnbView({required this.data});
  final _OnbData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 140,
            width: 140,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: 40),
          Text(data.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(data.body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
