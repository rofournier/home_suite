import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sprites nuages décodés (`ui.Image`) prêts pour le `CustomPainter` des
/// effets météo. Groupés par gabarit pour la sélection selon la condition.
class CloudSprites {
  const CloudSprites({
    required this.small,
    required this.medium,
    required this.large,
    required this.storm,
  });

  final List<ui.Image> small;
  final List<ui.Image> medium;
  final ui.Image large;
  final List<ui.Image> storm;
}

Future<ui.Image> _decode(String asset) async {
  final data = await rootBundle.load(asset);
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  return frame.image;
}

/// Décode une fois les planches nuages. Tant que non résolu, les effets
/// retombent sur des nuages procéduraux (aucun écran vide).
final cloudSpritesProvider = FutureProvider<CloudSprites>((ref) async {
  Future<ui.Image> load(String name) =>
      _decode('assets/weather/clouds/$name.png');
  final images = await Future.wait([
    load('cloud_small_1'),
    load('cloud_small_2'),
    load('cloud_medium_1'),
    load('cloud_medium_2'),
    load('cloud_large'),
    load('cloud_storm_1'),
    load('cloud_storm_2'),
  ]);
  return CloudSprites(
    small: [images[0], images[1]],
    medium: [images[2], images[3]],
    large: images[4],
    storm: [images[5], images[6]],
  );
});
