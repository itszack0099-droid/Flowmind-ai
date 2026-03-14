import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OrbBackground extends StatelessWidget {
  final Widget child;

  const OrbBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base background
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgDark : AppColors.bgLight,
          ),
        ),

        // Top-left purple orb
        Positioned(
          top: -80,
          left: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.purpleOrb.withOpacity(isDark ? 0.7 : 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Bottom-right orange orb
        Positioned(
          bottom: -60,
          right: -40,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.orangeOrb.withOpacity(isDark ? 0.6 : 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Small top-right purple dot
        Positioned(
          top: 80,
          right: 30,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.purple.withOpacity(isDark ? 0.8 : 0.4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),

        // Bottom-left small orb
        Positioned(
          bottom: 100,
          left: 20,
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.orangeOrb.withOpacity(isDark ? 0.8 : 0.4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orangeOrb.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),

        // Stars/particles effect (dark mode only)
        if (isDark)
          Positioned.fill(
            child: CustomPaint(
              painter: _StarsPainter(),
            ),
          ),

        // Main content
        child,
      ],
    );
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final stars = [
      Offset(size.width * 0.15, size.height * 0.15),
      Offset(size.width * 0.75, size.height * 0.10),
      Offset(size.width * 0.45, size.height * 0.20),
      Offset(size.width * 0.85, size.height * 0.35),
      Offset(size.width * 0.25, size.height * 0.50),
      Offset(size.width * 0.60, size.height * 0.45),
      Offset(size.width * 0.10, size.height * 0.70),
      Offset(size.width * 0.90, size.height * 0.65),
      Offset(size.width * 0.35, size.height * 0.80),
      Offset(size.width * 0.70, size.height * 0.85),
      Offset(size.width * 0.50, size.height * 0.60),
      Offset(size.width * 0.80, size.height * 0.20),
    ];

    for (final star in stars) {
      canvas.drawCircle(star, 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter oldDelegate) => false;
}
