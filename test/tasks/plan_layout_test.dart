import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/features/tasks/domain/plan_layout.dart';

void main() {
  test('conteneur plus large que le plan → letterbox horizontal centré', () {
    const container = Size(2000, 500);
    final rect = containedPlanRect(container);
    expect(rect.height, 500);
    expect(rect.width, closeTo(500 * planImageAspect, 0.001));
    expect(rect.center.dx, closeTo(1000, 0.001));
    expect(rect.top, 0);
  });

  test('conteneur plus haut que le plan → letterbox vertical centré', () {
    const container = Size(872, 2000);
    final rect = containedPlanRect(container);
    expect(rect.width, 872);
    expect(rect.height, closeTo(532, 0.001));
    expect(rect.center.dy, closeTo(1000, 0.001));
    expect(rect.left, 0);
  });

  test('normalize/denormalize : aller-retour stable', () {
    final plan = containedPlanRect(const Size(1200, 700));
    const normalized = Offset(0.25, 0.8);
    final abs = denormalizeInPlan(normalized, plan);
    final back = normalizeInPlan(abs, plan)!;
    expect(back.dx, closeTo(0.25, 0.0001));
    expect(back.dy, closeTo(0.8, 0.0001));
  });

  test('normalize hors du plan → null', () {
    final plan = containedPlanRect(const Size(2000, 500));
    expect(normalizeInPlan(const Offset(1, 250), plan), isNull); // letterbox
    expect(normalizeInPlan(plan.center, plan), isNotNull);
  });
}
