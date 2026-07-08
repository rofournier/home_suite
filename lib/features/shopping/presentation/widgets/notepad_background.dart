import 'package:flutter/material.dart';

import '../../../../app/theme_tokens.dart';

/// Fond « feuille de cahier » : papier crème + réglure horizontale discrète.
/// Espacement = [lineSpacing] (calé sur la hauteur de row pour l'alignement).
/// Purement décoratif (0 asset généré).
class NotepadBackground extends StatelessWidget {
  const NotepadBackground({
    super.key,
    required this.child,
    this.lineSpacing = 48,
  });

  final Widget child;
  final double lineSpacing;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.paper),
      child: CustomPaint(
        painter: _RuledPaperPainter(lineSpacing: lineSpacing),
        child: child,
      ),
    );
  }
}

class _RuledPaperPainter extends CustomPainter {
  const _RuledPaperPainter({required this.lineSpacing});

  final double lineSpacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.paperLine
      ..strokeWidth = 1;
    for (var y = lineSpacing; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_RuledPaperPainter oldDelegate) =>
      oldDelegate.lineSpacing != lineSpacing;
}
