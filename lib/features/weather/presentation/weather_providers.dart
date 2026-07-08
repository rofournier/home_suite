import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../location/presentation/location_providers.dart';
import '../data/open_meteo_datasource.dart';
import '../data/weather_repository_impl.dart';
import '../domain/weather.dart';
import '../domain/weather_repository.dart';

final _httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final _datasourceProvider = Provider<OpenMeteoDatasource>(
  (ref) => OpenMeteoDatasource(ref.watch(_httpClientProvider)),
);

final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => WeatherRepositoryImpl(ref.watch(_datasourceProvider)),
);

/// Météo courante + prévisions, dérivée de la localisation.
final weatherProvider = FutureProvider<Weather>((ref) async {
  final coordinates = await ref.watch(locationProvider.future);
  return ref.watch(weatherRepositoryProvider).getWeather(coordinates);
});
