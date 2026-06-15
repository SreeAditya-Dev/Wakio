import 'package:flutter/material.dart';

/// App brand mark: the Wakio logo (icon + wordmark).
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: size,
      fit: BoxFit.contain,
    );
  }
}
