import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/features/house/domain/house_layout.dart';

void main() {
  group('containedHouseRect', () {
    test('conteneur plus étroit que l\'image → calé en bas, pleine largeur', () {
      final rect = containedHouseRect(const Size(300, 900));
      expect(rect.width, 300);
      expect(rect.height, closeTo(300 / houseImageAspect, 0.001));
      expect(rect.bottom, 900); // ancrage bas
      expect(rect.left, 0);
    });

    test('conteneur plus large que l\'image → pleine hauteur, centré', () {
      final rect = containedHouseRect(const Size(1000, 600));
      expect(rect.height, 600);
      expect(rect.width, closeTo(600 * houseImageAspect, 0.001));
      expect(rect.center.dx, closeTo(500, 0.001));
      expect(rect.bottom, 600);
    });
  });

  group('placeInHouse', () {
    test('projette un rect normalisé dans le rect image', () {
      const image = Rect.fromLTWH(0, 100, 300, 450);
      final placed = placeInHouse(const Rect.fromLTWH(0.5, 0, 0.25, 0.2), image);
      expect(placed.left, closeTo(150, 0.001));
      expect(placed.top, closeTo(100, 0.001));
      expect(placed.width, closeTo(75, 0.001));
      expect(placed.height, closeTo(90, 0.001));
    });

    test('un hotspot dans la bande de ciel resterait hors image', () {
      // Avec l'ancien calcul (relatif à l\'écran), y=0.06 tombait dans le
      // letterbox ; ancré sur l\'image, tout hotspot 0..1 reste dans le rect.
      const image = Rect.fromLTWH(0, 300, 1080, 1620);
      final placed = placeInHouse(const Rect.fromLTWH(0.75, 0.63, 0.18, 0.12), image);
      expect(image.contains(placed.topLeft), isTrue);
      expect(image.contains(placed.bottomRight.translate(-0.01, -0.01)), isTrue);
    });
  });
}
