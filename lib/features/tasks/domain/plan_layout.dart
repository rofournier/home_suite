import 'dart:ui';

/// Géométrie du plan (asset 872×532, paysage). Le plan est affiché en
/// `contain` **centré** dans son conteneur ; les pins vivent en coordonnées
/// normalisées (0-1) relatives à l'image. Pur → testable.
const double planImageAspect = 872 / 532;

/// Rect réel occupé par l'image du plan dans [container] (contain + centré).
Rect containedPlanRect(Size container, {double aspect = planImageAspect}) {
  final fitByWidth = container.width / container.height <= aspect;
  final width = fitByWidth ? container.width : container.height * aspect;
  final height = width / aspect;
  return Rect.fromLTWH(
    (container.width - width) / 2,
    (container.height - height) / 2,
    width,
    height,
  );
}

/// Position absolue → normalisée (0-1) dans [plan]. `null` si hors du plan.
Offset? normalizeInPlan(Offset position, Rect plan) {
  if (!plan.contains(position)) return null;
  return Offset(
    (position.dx - plan.left) / plan.width,
    (position.dy - plan.top) / plan.height,
  );
}

/// Position normalisée (0-1) → absolue dans [plan].
Offset denormalizeInPlan(Offset normalized, Rect plan) => Offset(
      plan.left + normalized.dx * plan.width,
      plan.top + normalized.dy * plan.height,
    );
