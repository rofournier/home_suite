import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/features/tasks/domain/scoring.dart';

void main() {
  test('points = sévérité, bornés [1..3]', () {
    expect(pointsForSeverity(1), 1);
    expect(pointsForSeverity(3), 3);
    expect(pointsForSeverity(0), 1);
    expect(pointsForSeverity(9), 3);
  });

  test('titres par paliers', () {
    expect(titleForPoints(0), 'Apprenti balai');
    expect(titleForPoints(9), 'Apprenti balai');
    expect(titleForPoints(10), 'Fée du logis');
    expect(titleForPoints(24), 'Fée du logis');
    expect(titleForPoints(25), 'Chef de chantier');
    expect(titleForPoints(49), 'Chef de chantier');
    expect(titleForPoints(50), 'Légende du foyer');
  });
}
