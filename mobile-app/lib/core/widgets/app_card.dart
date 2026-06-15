import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rounded surface container used across the app for grouped content.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.gradient,
    this.border,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppColorsExt>()!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null ? ext.card : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            border: border,
          ),
          child: child,
        ),
      ),
    );
  }
}
