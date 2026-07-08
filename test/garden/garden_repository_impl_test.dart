import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/core/files/local_image_store.dart';
import 'package:home_sweet_home/features/garden/data/garden_events.dart';
import 'package:home_sweet_home/features/garden/data/garden_local_datasource.dart';
import 'package:home_sweet_home/features/garden/data/garden_repository_impl.dart';
import 'package:home_sweet_home/features/garden/domain/garden.dart';
import 'package:home_sweet_home/features/household/domain/household.dart';
import 'package:home_sweet_home/features/household/domain/room.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shopping/fakes.dart';

class SeqGardenIds extends GardenIdGenerator {
  int _n = 0;
  @override
  String next() => 'id${_n++}';
}

void main() {
  const household = Household(
    id: 'h',
    name: 'Ma maison',
    members: [Member(id: 'me', displayName: 'Moi')],
  );
  const me = Member(id: 'me', displayName: 'Moi');

  late Directory tempDir;
  late FakeRealtimeService realtime;
  late GardenLocalDatasource datasource;
  late DateTime clock;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hsh_garden_test');
    clock = DateTime(2026, 7, 8);
  });
  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  Future<GardenRepositoryImpl> build() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    datasource = GardenLocalDatasource(prefs);
    realtime = FakeRealtimeService();
    return GardenRepositoryImpl(
      datasource: datasource,
      imageStore:
          LocalImageStore(subdir: 'garden', baseDir: () async => tempDir),
      realtime: realtime,
      household: household,
      currentMember: me,
      idGenerator: SeqGardenIds(),
      clock: () => clock,
    );
  }

  test('addPlant crée la plante, persiste et publie une sync', () async {
    final repo = await build();
    final plant = await repo.addPlant(
        name: 'Ficus', room: Room.salon, waterEveryDays: 3, note: 'mi-ombre');

    expect(plant.name, 'Ficus');
    expect(plant.lastWateredAt, isNull);
    expect(datasource.load('h')!.plants, hasLength(1));
    expect(realtime.published.where((e) => e.type == GardenEvents.sync),
        hasLength(1));
  });

  test('waterPlant met à jour date/auteur/historique et renvoie l\'état '
      'précédent (undo)', () async {
    final repo = await build();
    final plant = await repo.addPlant(
        name: 'Ficus', room: Room.salon, waterEveryDays: 3);

    final previous = await repo.waterPlant(plant.id);

    expect(previous!.lastWateredAt, isNull);
    final watered = (await repo.watch().first).plantById(plant.id)!;
    expect(watered.lastWateredAt, clock);
    expect(watered.lastWateredBy, 'me');
    expect(watered.history.single.by, 'me');

    // Undo : restaure l'état précédent.
    await repo.restorePlants([previous]);
    final restored = (await repo.watch().first).plantById(plant.id)!;
    expect(restored.lastWateredAt, isNull);
    expect(restored.history, isEmpty);
  });

  test('waterRoom arrose toutes les plantes de la pièce seulement', () async {
    final repo = await build();
    final salon1 = await repo.addPlant(
        name: 'Ficus', room: Room.salon, waterEveryDays: 3);
    final salon2 = await repo.addPlant(
        name: 'Pothos', room: Room.salon, waterEveryDays: 5);
    final balcon = await repo.addPlant(
        name: 'Basilic', room: Room.balcon, waterEveryDays: 1);

    final previous = await repo.waterRoom(Room.salon);

    expect(previous, hasLength(2));
    final garden = await repo.watch().first;
    expect(garden.plantById(salon1.id)!.lastWateredAt, clock);
    expect(garden.plantById(salon2.id)!.lastWateredAt, clock);
    expect(garden.plantById(balcon.id)!.lastWateredAt, isNull);
  });

  test('historique plafonné à $maxWateringHistory arrosages', () async {
    final repo = await build();
    final plant = await repo.addPlant(
        name: 'Ficus', room: Room.salon, waterEveryDays: 3);

    for (var i = 0; i < maxWateringHistory + 5; i++) {
      clock = clock.add(const Duration(days: 1));
      await repo.waterPlant(plant.id);
    }

    final watered = (await repo.watch().first).plantById(plant.id)!;
    expect(watered.history, hasLength(maxWateringHistory));
    // Le plus récent en tête.
    expect(watered.history.first.at, clock);
  });

  test('feedPlant met à jour date/auteur/historique engrais + undo', () async {
    final repo = await build();
    final plant = await repo.addPlant(
        name: 'Ficus', room: Room.salon, waterEveryDays: 3, feedEveryDays: 30);

    final previous = await repo.feedPlant(plant.id);

    expect(previous!.lastFedAt, isNull);
    final fed = (await repo.watch().first).plantById(plant.id)!;
    expect(fed.lastFedAt, clock);
    expect(fed.lastFedBy, 'me');
    expect(fed.feedHistory.single.by, 'me');
    // L'arrosage n'est pas touché.
    expect(fed.lastWateredAt, isNull);
    expect(fed.history, isEmpty);

    await repo.restorePlants([previous]);
    final restored = (await repo.watch().first).plantById(plant.id)!;
    expect(restored.lastFedAt, isNull);
    expect(restored.feedHistory, isEmpty);
  });

  test('fréquence bornée [1..60]', () async {
    final repo = await build();
    final plant = await repo.addPlant(
        name: 'Cactus', room: Room.balcon, waterEveryDays: 999);
    expect(plant.waterEveryDays, 60);
  });

  test('applyRemote LWW : ignore plus vieux, applique plus récent', () async {
    final repo = await build();
    await repo.addPlant(name: 'Ficus', room: Room.salon, waterEveryDays: 3);

    final stale = Garden(
        householdId: 'h', plants: const [], updatedAt: DateTime(2026, 7, 1));
    await repo.applyRemote(stale);
    expect((await repo.watch().first).plants, hasLength(1));

    final fresh = Garden(
        householdId: 'h', plants: const [], updatedAt: DateTime(2026, 7, 9));
    await repo.applyRemote(fresh);
    expect((await repo.watch().first).plants, isEmpty);
  });

  test('deletePlant retire la plante', () async {
    final repo = await build();
    final plant = await repo.addPlant(
        name: 'Ficus', room: Room.salon, waterEveryDays: 3);
    await repo.deletePlant(plant.id);
    expect((await repo.watch().first).plants, isEmpty);
  });

  test('republish publie l\'état local', () async {
    final repo = await build();
    await repo.addPlant(name: 'Ficus', room: Room.salon, waterEveryDays: 3);
    realtime.published.clear();

    await repo.republish();
    expect(realtime.published.where((e) => e.type == GardenEvents.sync),
        hasLength(1));
  });
}
