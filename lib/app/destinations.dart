import 'package:flutter/material.dart';

/// Les mini-apps atteignables depuis le hub. En V1 toutes (sauf settings)
/// ouvrent un écran placeholder ; les routes sont déjà câblées.
enum AppDestination {
  shopping('/shopping', 'Courses', Icons.shopping_basket_outlined),
  housePlan('/house-plan', 'Plan', Icons.map_outlined),
  documents('/documents', 'Documents', Icons.folder_outlined),
  paint('/paint', 'Paint', Icons.brush_outlined),
  gallery('/gallery', 'Galerie', Icons.image_outlined),
  mirror('/mirror', 'Miroir', Icons.crop_portrait_outlined),
  garden('/garden', 'Jardin', Icons.local_florist_outlined),
  settings('/settings', 'Réglages', Icons.settings_outlined);

  const AppDestination(this.route, this.label, this.icon);

  final String route;
  final String label;
  final IconData icon;
}
