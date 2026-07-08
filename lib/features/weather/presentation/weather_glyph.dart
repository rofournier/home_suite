import 'package:flutter/material.dart';

import '../../hub/domain/weather_scene.dart';
import '../domain/weather_condition.dart';

enum GlyphKind { sun, moon, cloud }

GlyphKind glyphForScene(WeatherScene scene) {
  if (scene.condition == SkyCondition.clear) {
    return scene.isDay ? GlyphKind.sun : GlyphKind.moon;
  }
  return GlyphKind.cloud;
}

/// Dessine soleil / lune / nuage en vectoriel (crisp). Soleil = simple disque
/// (ni rayons ni halo, choix produit).
class WeatherGlyphPainter extends CustomPainter {
  WeatherGlyphPainter({required this.kind});

  final GlyphKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case GlyphKind.sun:
        _sun(canvas, size);
      case GlyphKind.moon:
        _moon(canvas, size);
      case GlyphKind.cloud:
        _cloud(canvas, size);
    }
  }

  void _sun(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide * 0.32;
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFFF2C078));
  }

  void _moon(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide * 0.28;
    final moon = Paint()..color = const Color(0xFFE8C98A);
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawCircle(center, r, moon);
    canvas.drawCircle(
      center.translate(r * 0.55, -r * 0.35),
      r * 0.95,
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();
  }

  void _cloud(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final w = size.width;
    final h = size.height;
    canvas.drawOval(
        Rect.fromLTWH(w * 0.2, h * 0.45, w * 0.6, h * 0.32), paint);
    canvas.drawCircle(Offset(w * 0.4, h * 0.48), w * 0.16, paint);
    canvas.drawCircle(Offset(w * 0.6, h * 0.44), w * 0.19, paint);
  }

  @override
  bool shouldRepaint(WeatherGlyphPainter oldDelegate) =>
      oldDelegate.kind != kind;
}
