import 'package:flutter/widgets.dart';

import '../../../app/destinations.dart';

/// Zone cliquable posée sur la maison. [area] est normalisée (0..1) dans le
/// rectangle de la maison → indépendante de la résolution. Réutilisable entre
/// versions (Cosy/Riad partagent le même plan).
class Hotspot {
  const Hotspot(this.destination, this.area);

  final AppDestination destination;
  final Rect area;
}

/// Mapping par défaut (voir docs/BRIEF.md §10). Coords normalisées **dans
/// l'image maison** (pas l'écran) → calées sur les objets réels du PNG. Rects
/// généreux (tap sans zoom). Cosy et Riad partagent ce plan 1:1.
final defaultHotspots = <Hotspot>[
  // Étage haut : bureau · atelier (chevalet) · salle de bain (miroir)
  Hotspot(AppDestination.documents, const Rect.fromLTWH(0.06, 0.24, 0.27, 0.15)),
  Hotspot(AppDestination.paint, const Rect.fromLTWH(0.36, 0.23, 0.27, 0.16)),
  Hotspot(AppDestination.mirror, const Rect.fromLTWH(0.66, 0.24, 0.28, 0.15)),
  // Étage milieu : cuisine (frigo+liste) · salon (tableau) · plan (blueprint)
  Hotspot(AppDestination.shopping, const Rect.fromLTWH(0.06, 0.44, 0.27, 0.15)),
  Hotspot(AppDestination.gallery, const Rect.fromLTWH(0.34, 0.45, 0.31, 0.14)),
  Hotspot(AppDestination.housePlan, const Rect.fromLTWH(0.66, 0.45, 0.28, 0.14)),
  // Réglages : cadran mural (thermostat) au rez-de-chaussée, à droite
  Hotspot(AppDestination.settings, const Rect.fromLTWH(0.75, 0.63, 0.18, 0.12)),
  // Jardin / potager (bas gauche)
  Hotspot(AppDestination.garden, const Rect.fromLTWH(0.05, 0.81, 0.34, 0.09)),
];
