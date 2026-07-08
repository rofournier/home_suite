import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../app/theme_tokens.dart';

/// Petite explosion d'étoiles jouée à la disparition d'un pin (célébration).
/// Auto-animée une seule fois (~600 ms) ; le parent retire le widget après.
class StarBurst extends StatelessWidget {
  const StarBurst({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: 64,
        height: 64,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (_, t, _) => CustomPaint(painter: _BurstPainter(t)),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.t);

  final double t;

  static const _colors = [
    AppColors.amber,
    AppColors.terracotta,
    AppColors.sage,
    AppColors.moonGold,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final center = size.center(Offset.zero);
    final opacity = (1 - t).clamp(0.0, 1.0);
    for (var i = 0; i < 8; i++) {
      final angle = i * pi / 4 + 0.3; // léger décalage : moins mécanique
      final distance = 6 + t * 24;
      final position = center +
          Offset(cos(angle) * distance, sin(angle) * distance);
      final paint = Paint()
        ..color = _colors[i % _colors.length].withValues(alpha: opacity);
      canvas.drawCircle(position, 3.2 * (1 - t) + 0.8, paint);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) => oldDelegate.t != t;
}
