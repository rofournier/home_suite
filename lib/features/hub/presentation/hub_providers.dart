import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../weather/presentation/weather_providers.dart';
import '../domain/weather_scene.dart';

/// Scène météo courante avec repli (clearDay) tant que la météo charge/échoue.
final weatherSceneProvider = Provider<WeatherScene>((ref) {
  final weather = ref.watch(weatherProvider);
  return switch (weather) {
    AsyncData(:final value) => WeatherScene.fromWeather(value),
    _ => WeatherScene.clearDay,
  };
});
