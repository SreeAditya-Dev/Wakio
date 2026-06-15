import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';

/// Bottom-nav scaffold wrapping the four primary tabs.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    (Routes.home, Icons.home_rounded, Icons.home_outlined, 'Home'),
    (Routes.alarms, Icons.alarm_rounded, Icons.alarm_outlined, 'Alarms'),
    (Routes.stats, Icons.insights_rounded, Icons.insights_outlined, 'Stats'),
    (Routes.profile, Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
  ];

  int _indexFor(String location) {
    final i = _tabs.indexWhere((t) => t.$1 == location);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _indexFor(location);

    return Scaffold(
      // Let body content slide *under* the floating nav so the frosted bar has
      // something to blur (and the glow shows through its edges).
      extendBody: true,
      body: child,
      bottomNavigationBar: _FloatingNavBar(
        selectedIndex: index,
        onSelect: (i) => context.go(_tabs[i].$1),
        tabs: _tabs,
      ),
    );
  }
}

/// Black rounded-pill bottom nav. The active tab expands into a smaller
/// dark pill with an icon + label; inactive tabs show plain outline icons.
class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<(String, IconData, IconData, String)> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Frosted-glass pill. A single BackdropFilter over a small, static region
    // is cheap; the content scrolling underneath shows through softly blurred.
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset + 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                // Tinted, semi-transparent so the blur reads as frosted glass
                // rather than a solid bar.
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: isDark ? 0.08 : 0.55),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < tabs.length; i++)
                    _NavItem(
                      icon: tabs[i].$3,
                      activeIcon: tabs[i].$2,
                      label: tabs[i].$4,
                      selected: i == selectedIndex,
                      onTap: () => onSelect(i),
                      isDark: isDark,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Light theme: black bar + dark-gray active pill, white content.
    // Dark theme: charcoal bar + orange active pill, near-black content
    // so the active tab still pops against the dark background.
    final pillColor = isDark ? AppColors.primary : const Color(0xFF2A2A2A);
    final activeContentColor = isDark ? AppColors.onPrimary : Colors.white;
    const inactiveContentColor = Colors.white;

    return Material(
      color: Colors.transparent,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: selected
              ? const EdgeInsets.symmetric(horizontal: 18, vertical: 12)
              : const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? pillColor : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? activeIcon : icon,
                color: selected ? activeContentColor : inactiveContentColor,
                size: 24,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          label,
                          style: GoogleFonts.inter(
                            color: activeContentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
