import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/core/persistence/shared_preferences_provider.dart';
import 'package:home_sweet_home/app/realtime_binding.dart';
import 'package:home_sweet_home/features/shopping/presentation/shopping_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

Future<Widget> harness() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      realtimeServiceProvider.overrideWithValue(FakeRealtimeService()),
    ],
    child: const MaterialApp(home: ShoppingScreen()),
  );
}

void main() {
  testWidgets('affiche les onglets seedés', (tester) async {
    await tester.pumpWidget(await harness());
    await tester.pumpAndSettle();

    expect(find.text('Frais'), findsOneWidget);
    expect(find.text('Maison'), findsOneWidget);
    expect(find.text('Pharmacie'), findsOneWidget);
    // Ligne d'écriture toujours présente (pas de bouton d'ajout).
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('ajouter puis cocher un article', (tester) async {
    await tester.pumpWidget(await harness());
    await tester.pumpAndSettle();

    // Saisit dans la ligne d'écriture puis valide (Entrée) → article créé.
    await tester.enterText(find.byType(TextField).first, 'Tomates');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pumpAndSettle();
    expect(find.text('Tomates'), findsOneWidget);

    // Coche → l'icône passe à l'état « acheté ».
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    await tester.tap(find.byIcon(Icons.radio_button_unchecked));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    // Le bouton de nettoyage apparaît quand il y a un acheté.
    expect(find.textContaining('Nettoyer'), findsOneWidget);
  });

  testWidgets('créer un onglet via le dialogue', (tester) async {
    await tester.pumpWidget(await harness());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Nouvel onglet'));
    await tester.pumpAndSettle();
    // Le champ du dialogue est le dernier (la ligne d'écriture reste dessous).
    await tester.enterText(find.byType(TextField).last, 'Bricolage');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Bricolage'), findsOneWidget);
  });
}
