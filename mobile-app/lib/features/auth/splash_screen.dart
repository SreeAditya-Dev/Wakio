import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_logo.dart';

/// Shown while [AuthController] restores the session. The router redirects away
/// once auth state resolves.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BrandLogo(size: 96),
            SizedBox(height: 28),
            SizedBox(
              height: 26,
              width: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
