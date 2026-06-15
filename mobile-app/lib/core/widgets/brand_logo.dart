import 'package:flutter/material.dart';

/// App brand mark: the Wakio logo (icon + wordmark).
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/images/logo.png',
        height: size,
        width: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
