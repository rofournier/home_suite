import '../../weather/domain/weather.dart';
import '../../weather/domain/weather_condition.dart';

/// Vue synthétique de la météo pour piloter le rendu du hub (ciel + effets).
class WeatherScene {
  const WeatherScene({
    required this.condition,
    required this.isDay,
    required this.windSpeed,
  });

  final SkyCondition condition;
  final bool isDay;
  final double windSpeed; // km/h

  factory WeatherScene.fromWeather(Weather weather) => WeatherScene(
        condition: weather.condition,
        isDay: weather.isDay,
        windSpeed: weather.windSpeed,
      );

  /// Repli tant que la météo n'est pas chargée / en erreur.
  static const clearDay =
      WeatherScene(condition: SkyCondition.clear, isDay: true, windSpeed: 6);
}
