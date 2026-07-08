import 'package:flutter/material.dart';

import '../../weather/domain/weather_condition.dart';

/// Dégradé de ciel (haut→bas) + présence d'étoiles, selon condition + heure.
class SkyPalette {
  const SkyPalette(this.top, this.bottom, {this.showStars = false});

  final Color top;
  final Color bottom;
  final bool showStars;
}

SkyPalette skyPaletteFor(SkyCondition condition, bool isDay) {
  if (!isDay) {
    return switch (condition) {
      SkyCondition.clear || SkyCondition.partlyCloudy =>
        const SkyPalette(Color(0xFF2B2540), Color(0xFF4A3F63), showStars: true),
      SkyCondition.rain || SkyCondition.thunderstorm =>
        const SkyPalette(Color(0xFF1E2230), Color(0xFF343B4A)),
      _ => const SkyPalette(Color(0xFF2A2A33), Color(0xFF3E3E4A)),
    };
  }
  return switch (condition) {
    SkyCondition.clear =>
      const SkyPalette(Color(0xFFAFD4E6), Color(0xFFEAF1EA)),
    SkyCondition.partlyCloudy =>
      const SkyPalette(Color(0xFFB8D6E4), Color(0xFFEDECE4)),
    SkyCondition.cloudy || SkyCondition.fog =>
      const SkyPalette(Color(0xFFB9BEC2), Color(0xFFD7D3CC)),
    SkyCondition.rain =>
      const SkyPalette(Color(0xFF8A94A0), Color(0xFFB4B8BC)),
    SkyCondition.snow =>
      const SkyPalette(Color(0xFFC7CDD4), Color(0xFFEDEFF2)),
    SkyCondition.thunderstorm =>
      const SkyPalette(Color(0xFF6E7480), Color(0xFF9AA0A6)),
  };
}
