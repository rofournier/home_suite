import 'package:flutter/widgets.dart';

/// Ratio largeur/hauteur des PNG maison (1024×1536).
const double houseImageAspect = 1024 / 1536;

/// Rectangle réellement occupé par l'image maison dans [container], pour un
/// rendu `BoxFit.contain` calé en bas (`Alignment.bottomCenter`). Sert à ancrer
/// les hotspots sur l'image plutôt que sur la bande de ciel (letterbox).
Rect containedHouseRect(Size container, {double aspect = houseImageAspect}) {
  final fitByWidth = container.width / container.height <= aspect;
  final width = fitByWidth ? container.width : container.height * aspect;
  final height = fitByWidth ? container.width / aspect : container.height;
  final left = (container.width - width) / 2;
  final top = container.height - height; // ancrage bas
  return Rect.fromLTWH(left, top, width, height);
}

/// Projette un rect normalisé (0..1 dans l'image) vers ses pixels réels dans
/// [image] (le rect renvoyé par [containedHouseRect]).
Rect placeInHouse(Rect normalized, Rect image) => Rect.fromLTWH(
      image.left + normalized.left * image.width,
      image.top + normalized.top * image.height,
      normalized.width * image.width,
      normalized.height * image.height,
    );
