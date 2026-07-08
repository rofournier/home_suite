import 'package:flutter/material.dart';

/// Palette warm lofi (voir docs/DESIGN.md). Source unique des couleurs :
/// aucun hex en dur ailleurs dans le code.
abstract final class AppColors {
  // Jour / chrome
  static const cream = Color(0xFFF3E9DC);
  static const sand = Color(0xFFE7D6C1);
  static const terracotta = Color(0xFFC97B5A);
  static const amber = Color(0xFFE9A96B);
  static const sage = Color(0xFF8FA98C);
  static const ink = Color(0xFF33291F);
  static const inkSoft = Color(0xFF6E5F52);

  // Nuit
  static const nightBase = Color(0xFF241F30);
  static const nightSurface = Color(0x8C282234); // rgba(40,34,52,.55)
  static const moonGold = Color(0xFFE8C98A);
  static const onNight = Color(0xFFF1E7D9);

  // Bloc-note (app Courses). Papier crème un ton au-dessus du chrome pour
  // détacher la feuille du fond ; ligne de cahier discrète ; surbrillance
  // d'insertion chaude et brève ; badge dopamine.
  static const paper = Color(0xFFFBF4E6);
  static const paperLine = Color(0x33C97B5A); // terracotta ~20 % : réglure douce
  static const insertHighlight = Color(0x33E9A96B); // amber ~20 % : flash de row
  static const dopamine = Color(0xFFC97B5A); // pastille compteur = terracotta
  static const onDopamine = Color(0xFFFDF6EC);
  static const boughtText = Color(0xFF6E5F52); // taupe : item barré, grisé mais ≥4.5:1 sur paper

  // App Jardin : fond champêtre vert d'eau pâle, un ton sous le sage.
  static const meadow = Color(0xFFEDF2E4);
}

/// Palette de l'app Dessin : les couleurs du thème + quelques teintes de jeu
/// (bleu/rose lofi). Seule source des couleurs de pinceau.
abstract final class PaintPalette {
  static const colors = [
    AppColors.ink,
    AppColors.terracotta,
    AppColors.amber,
    AppColors.sage,
    AppColors.moonGold,
    Color(0xFF5C7FA3), // bleu lofi
    Color(0xFFC98BA9), // rose lofi
    Color(0xFFFDF6EC), // craie (gomme visuelle sur papier)
  ];
}

/// Échelle d'espacement 4/8 dp.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

/// Rayons de coins (soft-clay / glass).
abstract final class AppRadii {
  static const button = 20.0;
  static const card = 28.0;
  static const container = 40.0;
  static const pill = 999.0;
}
