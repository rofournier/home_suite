// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Weather _$WeatherFromJson(Map<String, dynamic> json) => _Weather(
  temperature: (json['temperature'] as num).toDouble(),
  weatherCode: (json['weatherCode'] as num).toInt(),
  windSpeed: (json['windSpeed'] as num).toDouble(),
  isDay: json['isDay'] as bool,
  sunrise: DateTime.parse(json['sunrise'] as String),
  sunset: DateTime.parse(json['sunset'] as String),
  hourly: (json['hourly'] as List<dynamic>)
      .map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
      .toList(),
  daily: (json['daily'] as List<dynamic>)
      .map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WeatherToJson(_Weather instance) => <String, dynamic>{
  'temperature': instance.temperature,
  'weatherCode': instance.weatherCode,
  'windSpeed': instance.windSpeed,
  'isDay': instance.isDay,
  'sunrise': instance.sunrise.toIso8601String(),
  'sunset': instance.sunset.toIso8601String(),
  'hourly': instance.hourly.map((e) => e.toJson()).toList(),
  'daily': instance.daily.map((e) => e.toJson()).toList(),
};

_HourlyForecast _$HourlyForecastFromJson(Map<String, dynamic> json) =>
    _HourlyForecast(
      time: DateTime.parse(json['time'] as String),
      weatherCode: (json['weatherCode'] as num).toInt(),
      temperature: (json['temperature'] as num).toDouble(),
      precipitationProbability: (json['precipitationProbability'] as num)
          .toInt(),
    );

Map<String, dynamic> _$HourlyForecastToJson(_HourlyForecast instance) =>
    <String, dynamic>{
      'time': instance.time.toIso8601String(),
      'weatherCode': instance.weatherCode,
      'temperature': instance.temperature,
      'precipitationProbability': instance.precipitationProbability,
    };

_DailyForecast _$DailyForecastFromJson(Map<String, dynamic> json) =>
    _DailyForecast(
      date: DateTime.parse(json['date'] as String),
      weatherCode: (json['weatherCode'] as num).toInt(),
      tempMax: (json['tempMax'] as num).toDouble(),
      tempMin: (json['tempMin'] as num).toDouble(),
    );

Map<String, dynamic> _$DailyForecastToJson(_DailyForecast instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'weatherCode': instance.weatherCode,
      'tempMax': instance.tempMax,
      'tempMin': instance.tempMin,
    };
