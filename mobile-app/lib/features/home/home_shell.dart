import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

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
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_tabs[i].$1),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.$3),
              selectedIcon: Icon(t.$2),
              label: t.$4,
            ),
        ],
      ),
    );
  }
}
