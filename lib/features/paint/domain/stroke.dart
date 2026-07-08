import 'dart:ui';

/// Un trait de dessin : couleur, épaisseur, points dans l'ordre du geste.
/// Immuable ; la liste de traits forme le dessin (undo = retirer le dernier).
class Stroke {
  const Stroke({
    required this.color,
    required this.width,
    required this.points,
  });

  final Color color;
  final double width;
  final List<Offset> points;

  Stroke extend(Offset point) =>
      Stroke(color: color, width: width, points: [...points, point]);
}
