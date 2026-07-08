import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/features/weather/domain/weather_condition.dart';

void main() {
  group('skyConditionFromWmo', () {
    test('ciel clair', () {
      expect(skyConditionFromWmo(0), SkyCondition.clear);
      expect(skyConditionFromWmo(1), SkyCondition.clear);
    });

    test('nuages', () {
      expect(skyConditionFromWmo(2), SkyCondition.partlyCloudy);
      expect(skyConditionFromWmo(3), SkyCondition.cloudy);
    });

    test('brouillard', () {
      expect(skyConditionFromWmo(45), SkyCondition.fog);
      expect(skyConditionFromWmo(48), SkyCondition.fog);
    });

    test('pluie & averses', () {
      for (final code in [51, 61, 65, 80, 82]) {
        expect(skyConditionFromWmo(code), SkyCondition.rain, reason: 'code $code');
      }
    });

    test('neige', () {
      for (final code in [71, 75, 77, 85, 86]) {
        expect(skyConditionFromWmo(code), SkyCondition.snow, reason: 'code $code');
      }
    });

    test('orage', () {
      for (final code in [95, 96, 99]) {
        expect(skyConditionFromWmo(code), SkyCondition.thunderstorm);
      }
    });

    test('code inconnu → couvert (repli sûr)', () {
      expect(skyConditionFromWmo(1234), SkyCondition.cloudy);
    });
  });
}
