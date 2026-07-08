import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme_tokens.dart';

/// Thème clair (chrome jour). Titres Calistoga, corps Inter.
ThemeData buildLightTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.terracotta,
      brightness: Brightness.light,
      primary: AppColors.terracotta,
      surface: AppColors.cream,
    ),
    scaffoldBackgroundColor: AppColors.cream,
  );
  return base.copyWith(textTheme: _textTheme(base.textTheme, AppColors.ink));
}

/// Thème sombre (chrome nuit).
ThemeData buildDarkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.terracotta,
      brightness: Brightness.dark,
      primary: AppColors.amber,
      surface: AppColors.nightBase,
    ),
    scaffoldBackgroundColor: AppColors.nightBase,
  );
  return base.copyWith(textTheme: _textTheme(base.textTheme, AppColors.onNight));
}

TextTheme _textTheme(TextTheme base, Color color) {
  final body =
      GoogleFonts.interTextTheme(base).apply(bodyColor: color, displayColor: color);
  TextStyle? display(TextStyle? style) =>
      GoogleFonts.calistoga(textStyle: style, color: color);
  return body.copyWith(
    displayLarge: display(body.displayLarge),
    displayMedium: display(body.displayMedium),
    displaySmall: display(body.displaySmall),
    headlineLarge: display(body.headlineLarge),
    headlineMedium: display(body.headlineMedium),
    titleLarge: display(body.titleLarge),
  );
}
