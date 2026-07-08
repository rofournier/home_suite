import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../hub/presentation/hub_providers.dart';
import 'weather_glyph.dart';
import 'weather_panel_providers.dart';

/// Indicateur météo permanent (coin haut-droit). Soleil/lune/nuage vectoriel,
/// tap → toggle la carte météo. Cible ≥48dp, sans halo.
class WeatherIndicator extends ConsumerWidget {
  const WeatherIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = ref.watch(weatherSceneProvider);
    final kind = glyphForScene(scene);
    return Semantics(
      button: true,
      label: 'Météo, ${scene.condition.label}',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => ref.read(weatherPanelOpenProvider.notifier).toggle(),
          child: SizedBox(
            width: 52,
            height: 52,
            child: CustomPaint(painter: WeatherGlyphPainter(kind: kind)),
          ),
        ),
      ),
    );
  }
}
