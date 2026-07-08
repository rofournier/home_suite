import 'package:freezed_annotation/freezed_annotation.dart';

import 'weather_condition.dart';

part 'weather.freezed.dart';
part 'weather.g.dart';

/// Météo courante + prévisions horaires (24 h) et 7 jours. Forme interne
/// (≠ payload Open-Meteo, mappé dans le datasource). Sérialisable pour cache /
/// futur serveur.
@freezed
abstract class Weather with _$Weather {
  const factory Weather({
    required double temperature,
    required int weatherCode,
    required double windSpeed,
    required bool isDay,
    required DateTime sunrise,
    required DateTime sunset,
    required List<HourlyForecast> hourly,
    required List<DailyForecast> daily,
  }) = _Weather;
  const Weather._();

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  SkyCondition get condition => skyConditionFromWmo(weatherCode);
}

@freezed
abstract class HourlyForecast with _$HourlyForecast {
  const factory HourlyForecast({
    required DateTime time,
    required int weatherCode,
    required double temperature,
    required int precipitationProbability, // %
  }) = _HourlyForecast;
  const HourlyForecast._();

  factory HourlyForecast.fromJson(Map<String, dynamic> json) =>
      _$HourlyForecastFromJson(json);

  SkyCondition get condition => skyConditionFromWmo(weatherCode);
}

@freezed
abstract class DailyForecast with _$DailyForecast {
  const factory DailyForecast({
    required DateTime date,
    required int weatherCode,
    required double tempMax,
    required double tempMin,
  }) = _DailyForecast;
  const DailyForecast._();

  factory DailyForecast.fromJson(Map<String, dynamic> json) =>
      _$DailyForecastFromJson(json);

  SkyCondition get condition => skyConditionFromWmo(weatherCode);
}
