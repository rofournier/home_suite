import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ouverture de la carte météo (togglée par l'indicateur du coin).
class WeatherPanelOpen extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void close() => state = false;
}

final weatherPanelOpenProvider =
    NotifierProvider<WeatherPanelOpen, bool>(WeatherPanelOpen.new);

/// Vue de la carte météo : par heure (24 h) ou par jour (7 j).
enum WeatherRange { hourly, daily }

class WeatherRangeMode extends Notifier<WeatherRange> {
  @override
  WeatherRange build() => WeatherRange.daily;

  void set(WeatherRange range) => state = range;
}

final weatherRangeProvider =
    NotifierProvider<WeatherRangeMode, WeatherRange>(WeatherRangeMode.new);
