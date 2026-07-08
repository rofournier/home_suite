/// Condition météo synthétique, dérivée des codes WMO d'Open-Meteo et
/// utilisée pour piloter les effets visuels du hub + les icônes.
enum SkyCondition {
  clear('Ciel clair'),
  partlyCloudy('Peu nuageux'),
  cloudy('Couvert'),
  fog('Brouillard'),
  rain('Pluie'),
  snow('Neige'),
  thunderstorm('Orage');

  const SkyCondition(this.label);

  final String label;
}

/// Mappe un code WMO (Open-Meteo `weather_code`) vers une [SkyCondition].
/// Réf : https://open-meteo.com/en/docs (WMO Weather interpretation codes).
SkyCondition skyConditionFromWmo(int code) {
  return switch (code) {
    0 || 1 => SkyCondition.clear,
    2 => SkyCondition.partlyCloudy,
    3 => SkyCondition.cloudy,
    45 || 48 => SkyCondition.fog,
    71 || 73 || 75 || 77 || 85 || 86 => SkyCondition.snow,
    95 || 96 || 99 => SkyCondition.thunderstorm,
    // bruine, pluie, averses, pluie verglaçante
    51 || 53 || 55 || 56 || 57 || 61 || 63 || 65 || 66 || 67 || 80 || 81 || 82 =>
      SkyCondition.rain,
    _ => SkyCondition.cloudy,
  };
}
