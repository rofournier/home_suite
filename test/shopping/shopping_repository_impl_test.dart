import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/features/household/domain/household.dart';
import 'package:home_sweet_home/features/shopping/data/shopping_events.dart';
import 'package:home_sweet_home/features/shopping/data/shopping_local_datasource.dart';
import 'package:home_sweet_home/features/shopping/data/shopping_repository_impl.dart';
import 'package:home_sweet_home/features/shopping/domain/shopping_category.dart';
import 'package:home_sweet_home/features/shopping/domain/shopping_item.dart';
import 'package:home_sweet_home/features/shopping/domain/shopping_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

void main() {
  const household = Household(
    id: 'h',
    name: 'Ma maison',
    members: [Member(id: 'me', displayName: 'Moi')],
  );
  const me = Member(id: 'me', displayName: 'Moi');

  late FakeRealtimeService realtime;
  late ShoppingLocalDatasource datasource;

  Future<ShoppingRepositoryImpl> build() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    datasource = ShoppingLocalDatasource(prefs);
    realtime = FakeRealtimeService();
    return ShoppingRepositoryImpl(
      datasource: datasource,
      realtime: realtime,
      household: household,
      currentMember: me,
      idGenerator: SeqIdGenerator(),
      clock: () => DateTime(2026, 7, 8),
      seedCategories: const ['Frais', 'Maison'],
    );
  }

  test('premier flux = onglets seedés et persistés', () async {
    final repo = await build();
    final list = await repo.watch().first;
    expect(list.categories.map((c) => c.name), ['Frais', 'Maison']);
    // Persisté : un nouveau datasource relit le même état.
    expect(datasource.load('h')!.categories.length, 2);
  });

  test('addItem crée l\'article, le persiste et publie itemAdded', () async {
    final repo = await build();
    await repo.watch().first; // force le seed
    final catId = (await repo.watch().first).categories.first.id;

    final item = await repo.addItem(catId, text: 'Tomates');
    expect(item.text, 'Tomates');
    expect(item.createdBy, 'me');

    final added = realtime.published
        .where((e) => e.type == ShoppingEvents.itemAdded)
        .toList();
    expect(added, hasLength(1));
    expect(added.single.payload!['authorName'], 'Moi');
    expect((added.single.payload!['item'] as Map)['text'], 'Tomates');

    expect(datasource.load('h')!.categories.first.items.single.text, 'Tomates');
  });

  test('splitItem scinde et publie l\'article créé', () async {
    final repo = await build();
    final catId = (await repo.watch().first).categories.first.id;
    final a = await repo.addItem(catId, text: 'Pommes');

    final created = await repo.splitItem(catId, a.id, 3);
    expect(created.text, 'mes');
    final items = (await repo.watch().first).categories.first.items;
    expect(items.map((i) => i.text), ['Pom', 'mes']);
  });

  test('restoreItem réinsère à la position (Undo)', () async {
    final repo = await build();
    final catId = (await repo.watch().first).categories.first.id;
    final a = await repo.addItem(catId, text: 'A');
    await repo.addItem(catId, text: 'B');

    await repo.deleteItem(catId, a.id);
    expect((await repo.watch().first).categories.first.items.map((i) => i.text),
        ['B']);

    await repo.restoreItem(catId, a, 0);
    expect((await repo.watch().first).categories.first.items.map((i) => i.text),
        ['A', 'B']);
  });

  test('mergeItem renvoie la cible de focus', () async {
    final repo = await build();
    final catId = (await repo.watch().first).categories.first.id;
    final a = await repo.addItem(catId, text: 'Tom');
    final b = await repo.addItem(catId, text: 'ates');

    final res = await repo.mergeItem(catId, b.id);
    expect(res.focusItemId, a.id);
    expect(res.cursor, 3);
    expect((await repo.watch().first).categories.first.items.single.text,
        'Tomates');
  });

  test('addCategory renvoie l\'id créé', () async {
    final repo = await build();
    await repo.watch().first;
    final id = await repo.addCategory('Pharmacie');
    final names = {for (final c in (await repo.watch().first).categories) c.id: c.name};
    expect(names[id], 'Pharmacie');
  });

  test('clearEmpty retire les articles vides, garde les autres', () async {
    final repo = await build();
    final catId = (await repo.watch().first).categories.first.id;
    await repo.addItem(catId, text: 'Lait');
    await repo.addItem(catId, text: ''); // ligne ébauchée puis abandonnée
    await repo.addItem(catId, text: '   '); // que des espaces

    await repo.clearEmpty(catId);

    final items = (await repo.watch().first).categories.first.items;
    expect(items.map((i) => i.text), ['Lait']);
    expect(datasource.load('h')!.categories.first.items, hasLength(1));
  });

  test('clearEmpty sans article vide = no-op (aucune sync)', () async {
    final repo = await build();
    final catId = (await repo.watch().first).categories.first.id;
    await repo.addItem(catId, text: 'Pain');
    realtime.published.clear();

    await repo.clearEmpty(catId);
    expect(realtime.published, isEmpty);
  });

  test('chaque mutation publie une sync portant l\'état complet', () async {
    final repo = await build();
    final catId = (await repo.watch().first).categories.first.id;
    realtime.published.clear();

    await repo.addItem(catId, text: 'Lait');

    final syncs =
        realtime.published.where((e) => e.type == ShoppingEvents.sync).toList();
    expect(syncs, hasLength(1));
    final list = syncs.single.payload!['list'] as Map<String, dynamic>;
    final items = (list['categories'] as List).first['items'] as List;
    expect((items.single as Map)['text'], 'Lait');
  });

  test('applyRemote remplace la liste, persiste et n\'émet aucune publication',
      () async {
    final repo = await build();
    await repo.watch().first; // seed
    realtime.published.clear();

    final remote = ShoppingList(
      householdId: 'h',
      updatedAt: DateTime(2026, 7, 9), // plus récent que le seed local
      categories: [
        ShoppingCategory(id: 'rc', name: 'Reçu de Bob', items: [
          ShoppingItem(
            id: 'ri',
            text: 'Pain',
            createdBy: 'bob',
            createdAt: DateTime(2026, 7, 8),
          ),
        ]),
      ],
    );

    await repo.applyRemote(remote);

    final current = await repo.watch().first;
    expect(current.categories.single.name, 'Reçu de Bob');
    expect(datasource.load('h')!.categories.single.items.single.text, 'Pain');
    expect(realtime.published, isEmpty); // pas de boucle
  });

  test('applyRemote ignore un état plus vieux (LWW protège le hors ligne)',
      () async {
    final repo = await build();
    final catId = (await repo.watch().first).categories.first.id;
    await repo.addItem(catId, text: 'Modif hors ligne'); // stamp local 8/7

    final stale = ShoppingList(
      householdId: 'h',
      updatedAt: DateTime(2026, 7, 1), // état serveur d'avant nos modifs
      categories: const [],
    );
    await repo.applyRemote(stale);

    final current = await repo.watch().first;
    expect(current.categories.first.items.single.text, 'Modif hors ligne');
  });

  test('republish publie l\'état local sans le modifier', () async {
    final repo = await build();
    final catId = (await repo.watch().first).categories.first.id;
    await repo.addItem(catId, text: 'Lait');
    realtime.published.clear();

    await repo.republish();

    final syncs =
        realtime.published.where((e) => e.type == ShoppingEvents.sync).toList();
    expect(syncs, hasLength(1));
    final list = syncs.single.payload!['list'] as Map<String, dynamic>;
    final items = (list['categories'] as List).first['items'] as List;
    expect((items.single as Map)['text'], 'Lait');
  });
}
