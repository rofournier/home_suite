import '../../location/domain/coordinates.dart';
import 'weather.dart';

abstract interface class WeatherRepository {
  Future<Weather> getWeather(Coordinates coordinates);
}

/// Erreur de récupération météo (réseau / parsing / statut HTTP).
class WeatherException implements Exception {
  const WeatherException(this.message);

  final String message;

  @override
  String toString() => 'WeatherException: $message';
}
