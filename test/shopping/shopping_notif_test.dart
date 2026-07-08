import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/app/realtime_binding.dart';
import 'package:home_sweet_home/core/realtime/realtime_service.dart';
import 'package:home_sweet_home/features/shopping/data/shopping_events.dart';
import 'package:home_sweet_home/features/shopping/domain/shopping_item.dart';
import 'package:home_sweet_home/features/shopping/presentation/shopping_notif.dart';
import 'package:home_sweet_home/features/shopping/presentation/widgets/notepad_banner.dart';

import 'fakes.dart';

RealtimeEvent addedBy(String author, String text, {String category = 'c1'}) =>
    itemAddedEvent(
      householdId: 'h',
      categoryId: category,
      categoryName: 'Frais',
      authorName: author == 'me' ? 'Moi' : 'Marie',
      item: ShoppingItem(
        id: 'x',
        text: text,
        createdBy: author,
        createdAt: DateTime(2026),
      ),
    );

Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('mapping évènement → état de notif', () {
    late FakeRealtimeService realtime;
    late ProviderContainer container;

    setUp(() {
      realtime = FakeRealtimeService();
      container = ProviderContainer(
        overrides: [realtimeServiceProvider.overrideWithValue(realtime)],
      );
      // Garde le notifier vivant (souscription au flux).
      container.listen(shoppingNotifProvider, (_, _) {});
    });

    tearDown(() {
      container.dispose();
      realtime.dispose();
    });

    test('article d\'un coéquipier → badge onglet + bannière + compteur HUB',
        () async {
      realtime.emit(addedBy('marie', 'Pommes'));
      await settle();

      final state = container.read(shoppingNotifProvider);
      expect(state.unseenByCategory['c1'], 1);
      expect(state.hubUnseen, 1);
      expect(state.banner!.itemText, 'Pommes');
      expect(state.banner!.authorName, 'Marie');
      expect(container.read(hubShoppingUnseenProvider), 1);
    });

    test('mes propres ajouts sont ignorés (pas d\'auto-notif)', () async {
      realtime.emit(addedBy('me', 'Lait'));
      await settle();

      final state = container.read(shoppingNotifProvider);
      expect(state.hubUnseen, 0);
      expect(state.banner, isNull);
    });

    test('markCategorySeen efface le badge de l\'onglet', () async {
      realtime.emit(addedBy('marie', 'Pommes'));
      await settle();
      container.read(shoppingNotifProvider.notifier).markCategorySeen('c1');
      expect(container.read(shoppingNotifProvider).unseenByCategory['c1'], isNull);
    });

    test('resetHubUnseen remet le compteur dopamine à zéro', () async {
      realtime.emit(addedBy('marie', 'Pommes'));
      realtime.emit(addedBy('marie', 'Poires'));
      await settle();
      expect(container.read(hubShoppingUnseenProvider), 2);

      container.read(shoppingNotifProvider.notifier).resetHubUnseen();
      expect(container.read(hubShoppingUnseenProvider), 0);
    });
  });

  testWidgets('la bannière in-app s\'affiche puis s\'auto-efface', (tester) async {
    final realtime = FakeRealtimeService();
    addTearDown(realtime.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [realtimeServiceProvider.overrideWithValue(realtime)],
        child: const MaterialApp(home: Scaffold(body: NotepadBanner())),
      ),
    );

    realtime.emit(addedBy('marie', 'Pommes'));
    await tester.pump(); // livraison de l'évènement
    await tester.pump(const Duration(milliseconds: 250)); // fin d'anim d'entrée
    expect(find.textContaining('Pommes'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3)); // auto-dismiss
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.textContaining('Pommes'), findsNothing);
  });
}
