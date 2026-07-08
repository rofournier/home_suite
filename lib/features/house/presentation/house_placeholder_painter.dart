import 'package:flutter/material.dart';

import '../../../app/theme_tokens.dart';
import '../domain/house_version.dart';

/// Silhouette de maison dessinée en Flutter, en attendant les PNG générés.
/// Donne un repère visuel des pièces pour valider le placement des hotspots.
class HousePlaceholderPainter extends CustomPainter {
  const HousePlaceholderPainter(this.version);

  final HouseVersion version;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final wall =
        version == HouseVersion.riad ? const Color(0xFFE9D9C3) : AppColors.sand;
    final line = AppColors.inkSoft.withValues(alpha: 0.35);

    // Pelouse + potager (bas).
    final grass = Rect.fromLTWH(0, h * 0.84, w, h * 0.16);
    canvas.drawRect(grass, Paint()..color = AppColors.sage.withValues(alpha: 0.6));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.34, h * 0.86, w * 0.32, h * 0.09),
          const Radius.circular(8)),
      Paint()..color = const Color(0xFF7A5B3A).withValues(alpha: 0.8),
    );

    // Corps de la maison.
    final body = Rect.fromLTWH(w * 0.04, h * 0.2, w * 0.92, h * 0.64);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(10)),
      Paint()..color = wall,
    );

    // Toit.
    final roof = Path()
      ..moveTo(w * 0.02, h * 0.2)
      ..lineTo(w * 0.5, h * 0.04)
      ..lineTo(w * 0.98, h * 0.2)
      ..close();
    canvas.drawPath(roof, Paint()..color = AppColors.terracotta);

    // Séparations pièces (2 étages × 3).
    final stroke = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(
        Offset(w * 0.04, h * 0.52), Offset(w * 0.96, h * 0.52), stroke);
    for (final x in [0.35, 0.65]) {
      canvas.drawLine(
          Offset(w * x, h * 0.2), Offset(w * x, h * 0.84), stroke);
    }
  }

  @override
  bool shouldRepaint(HousePlaceholderPainter oldDelegate) =>
      oldDelegate.version != version;
}
