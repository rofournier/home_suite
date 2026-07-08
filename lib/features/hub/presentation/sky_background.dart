import 'dart:math';

import 'package:flutter/material.dart';

import '../../weather/domain/weather_condition.dart';
import '../domain/sky_palette.dart';

/// Ciel dynamique : dégradé selon la météo/heure + étoiles la nuit claire.
class SkyBackground extends StatelessWidget {
  const SkyBackground({super.key, required this.condition, required this.isDay});

  final SkyCondition condition;
  final bool isDay;

  @override
  Widget build(BuildContext context) {
    final palette = skyPaletteFor(condition, isDay);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.top, palette.bottom],
        ),
      ),
      child: palette.showStars
          ? const CustomPaint(painter: _StarsPainter(), size: Size.infinite)
          : null,
    );
  }
}

class _StarsPainter extends CustomPainter {
  const _StarsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(7);
    final paint = Paint();
    for (var i = 0; i < 50; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height * 0.55;
      final radius = rng.nextDouble() * 1.2 + 0.4;
      paint.color =
          Colors.white.withValues(alpha: rng.nextDouble() * 0.6 + 0.3);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter oldDelegate) => false;
}
