import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Frosted-glass surface (glassmorphism).
///
/// Glassmorphism only reads as "glass" when there's color *behind* it to
/// refract — wrap the screen body in [AmbientGlow] so these cards have
/// something to blur.
///
/// Performance: a real [BackdropFilter] is GPU-expensive and must re-sample on
/// every scroll frame. Use [blur] = true only for the handful of static hero
/// surfaces (nav bar, metric tiles, the challenge card). For repeated list rows
/// pass [blur] = false — you still get the translucent, light-bordered glass
/// look over the ambient glow, but without per-row backdrop sampling, so long
/// lists stay smooth on low-end devices.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.onTap,
    this.blur = true,
    this.tint,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  /// Real backdrop blur (static surfaces) vs. a cheap translucent fill (lists).
  final bool blur;

  /// Optional accent the glass is tinted with. Defaults to a neutral white frost.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final base = tint ?? Colors.white;

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        // Diagonal sheen: brighter at the top-left, fading out — reads as a
        // light catching the edge of a pane of glass.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            base.withValues(alpha: 0.14),
            base.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    Widget card = ClipRRect(
      borderRadius: radius,
      child: blur
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: surface,
            )
          : surface,
    );

    // Isolate the (relatively expensive) blur so it doesn't invalidate
    // alongside unrelated repaints.
    return RepaintBoundary(child: card);
  }
}

/// Paints soft, out-of-focus color blobs behind [child]. Without this the
/// glass cards would blur a flat black background and look like plain dark
/// panels; the glow gives the frost real color to refract.
///
/// Pure gradients (no blur) — effectively free to render.
class AmbientGlow extends StatelessWidget {
  const AmbientGlow({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _GlowField()),
        child,
      ],
    );
  }
}

class _GlowField extends StatelessWidget {
  const _GlowField();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          // Warm brand glow, top-right.
          Positioned(
            top: -120,
            right: -100,
            child: _Blob(color: AppColors.primary, size: 360, alpha: 0.22),
          ),
          // Cool counter-glow, bottom-left, for color variety in the frost.
          Positioned(
            bottom: -140,
            left: -110,
            child: _Blob(color: Color(0xFF6366F1), size: 340, alpha: 0.16),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size, required this.alpha});

  final Color color;
  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: alpha), Colors.transparent],
        ),
      ),
    );
  }
}

/// Shows a bottom sheet with a frosted-glass surface instead of a flat panel.
/// Use for sound pickers, action menus, etc.
Future<T?> showGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(top: false, child: builder(ctx)),
        ),
      ),
    ),
  );
}
