import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_sweet_home/app/realtime_binding.dart';
import 'package:home_sweet_home/app/theme.dart';
import 'package:home_sweet_home/core/persistence/shared_preferences_provider.dart';
import 'package:home_sweet_home/features/hub/presentation/hub_screen.dart';
import 'package:home_sweet_home/features/weather/domain/weather.dart';
import 'package:home_sweet_home/features/weather/presentation/weather_indicator.dart';
import 'package:home_sweet_home/features/weather/presentation/weather_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shopping/fakes.dart';

Weather _fakeWeather() => Weather(
      temperature: 20,
      weatherCode: 0,
      windSpeed: 8,
      isDay: true,
      sunrise: DateTime(2026, 1, 1, 7),
      sunset: DateTime(2026, 1, 1, 20),
      hourly: [
        for (var i = 0; i < 24; i++)
          HourlyForecast(
            time: DateTime(2026, 1, 1, i),
            weatherCode: i.isEven ? 0 : 3,
            temperature: 18,
            precipitationProbability: i.isEven ? 0 : 40,
          ),
      ],
      daily: [
        for (var i = 0; i < 7; i++)
          DailyForecast(
            date: DateTime(2026, 1, 1 + i),
            weatherCode: i.isEven ? 0 : 3,
            tempMax: 22,
            tempMin: 12,
          ),
      ],
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Le hub se construit avec une météo simulée', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weatherProvider.overrideWith((ref) async => _fakeWeather()),
          sharedPreferencesProvider.overrideWithValue(prefs),
          realtimeServiceProvider.overrideWithValue(FakeRealtimeService()),
        ],
        child: MaterialApp(theme: buildLightTheme(), home: const HubScreen()),
      ),
    );
    await tester.pump();

    expect(find.byType(HubScreen), findsOneWidget);
    expect(find.byType(WeatherIndicator), findsOneWidget);
  });
}
