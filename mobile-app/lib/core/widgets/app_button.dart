import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Primary brand button with a built-in loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(AppColors.onPrimary),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 10)],
              Text(label),
            ],
          );

    final button = ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: child,
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Secondary/outline variant used for less-prominent actions.
class AppOutlineButton extends StatelessWidget {
  const AppOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          side: BorderSide(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 10)],
            Text(label),
          ],
        ),
      ),
    );
  }
}
