import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/weather.dart';
import '../domain/weather_repository.dart';

/// Accès brut à l'API Open-Meteo (gratuite, sans clé) et mapping payload →
/// [Weather]. Aucune logique métier ici hors parsing.
class OpenMeteoDatasource {
  OpenMeteoDatasource(this._client);

  final http.Client _client;

  Future<Weather> fetch({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'current': 'temperature_2m,weather_code,wind_speed_10m,is_day',
      'hourly': 'temperature_2m,weather_code,precipitation_probability',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset',
      'timezone': 'auto',
      'forecast_days': '7',
    });

    final http.Response response;
    try {
      response = await _client.get(uri);
    } catch (e) {
      throw WeatherException('réseau: $e');
    }
    if (response.statusCode != 200) {
      throw WeatherException('HTTP ${response.statusCode}');
    }

    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return _parse(json);
    } catch (e) {
      throw WeatherException('parsing: $e');
    }
  }

  Weather _parse(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    final now = DateTime.parse(current['time'] as String);

    final dates = (daily['time'] as List).cast<String>();
    final codes = (daily['weather_code'] as List).cast<num>();
    final maxs = (daily['temperature_2m_max'] as List).cast<num>();
    final mins = (daily['temperature_2m_min'] as List).cast<num>();
    final sunrises = (daily['sunrise'] as List).cast<String>();
    final sunsets = (daily['sunset'] as List).cast<String>();

    final forecast = <DailyForecast>[
      for (var i = 0; i < dates.length; i++)
        DailyForecast(
          date: DateTime.parse(dates[i]),
          weatherCode: codes[i].toInt(),
          tempMax: maxs[i].toDouble(),
          tempMin: mins[i].toDouble(),
        ),
    ];

    return Weather(
      temperature: (current['temperature_2m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      isDay: (current['is_day'] as num) == 1,
      sunrise: DateTime.parse(sunrises.first),
      sunset: DateTime.parse(sunsets.first),
      hourly: _hourly(json['hourly'] as Map<String, dynamic>, now),
      daily: forecast,
    );
  }

  /// 24 prochaines heures à partir de l'heure courante (incluse).
  List<HourlyForecast> _hourly(Map<String, dynamic> hourly, DateTime now) {
    final times = (hourly['time'] as List).cast<String>();
    final temps = (hourly['temperature_2m'] as List).cast<num>();
    final codes = (hourly['weather_code'] as List).cast<num>();
    final pop = (hourly['precipitation_probability'] as List).cast<num?>();
    final currentHour = DateTime(now.year, now.month, now.day, now.hour);

    final result = <HourlyForecast>[];
    for (var i = 0; i < times.length && result.length < 24; i++) {
      final time = DateTime.parse(times[i]);
      if (time.isBefore(currentHour)) continue;
      result.add(HourlyForecast(
        time: time,
        weatherCode: codes[i].toInt(),
        temperature: temps[i].toDouble(),
        precipitationProbability: pop[i]?.toInt() ?? 0,
      ));
    }
    return result;
  }
}
