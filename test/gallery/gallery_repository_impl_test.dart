import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/core/files/local_image_store.dart';
import 'package:home_sweet_home/features/gallery/data/gallery_events.dart';
import 'package:home_sweet_home/features/gallery/data/gallery_local_datasource.dart';
import 'package:home_sweet_home/features/gallery/data/gallery_repository_impl.dart';
import 'package:home_sweet_home/features/gallery/domain/gallery_album.dart';
import 'package:home_sweet_home/features/household/domain/household.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../shopping/fakes.dart';

class SeqGalleryIds extends GalleryIdGenerator {
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
  late GalleryLocalDatasource datasource;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hsh_gallery_test');
  });
  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  Future<GalleryRepositoryImpl> build() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    datasource = GalleryLocalDatasource(prefs);
    realtime = FakeRealtimeService();
    return GalleryRepositoryImpl(
      datasource: datasource,
      imageStore:
          LocalImageStore(subdir: 'gallery', baseDir: () async => tempDir),
      realtime: realtime,
      household: household,
      currentMember: me,
      idGenerator: SeqGalleryIds(),
      clock: () => DateTime(2026, 7, 8),
    );
  }

  Future<String> drawing() async {
    final f = File(p.join(tempDir.path, 'src.png'));
    await f.writeAsBytes([9, 9, 9]);
    return f.path;
  }

  test('addDrawing copie le fichier, insère en tête et publie une sync',
      () async {
    final repo = await build();
    await repo.addDrawing(sourcePath: await drawing(), title: 'Ancien');
    final item =
        await repo.addDrawing(sourcePath: await drawing(), title: 'Récent');

    final album = await repo.watch().first;
    expect(album.items.first.title, 'Récent'); // plus récent en tête
    expect(album.items, hasLength(2));
    expect(File(item.imagePath).existsSync(), isTrue);
    expect(item.createdBy, 'me');
    expect(datasource.load('h')!.items, hasLength(2));
    expect(realtime.published.where((e) => e.type == GalleryEvents.sync),
        hasLength(2));
  });

  test('deleteItem retire l\'entrée et supprime le fichier', () async {
    final repo = await build();
    final item =
        await repo.addDrawing(sourcePath: await drawing(), title: 'A');

    await repo.deleteItem(item.id);

    expect((await repo.watch().first).items, isEmpty);
    expect(File(item.imagePath).existsSync(), isFalse);
  });

  test('applyRemote LWW : ignore plus vieux, applique plus récent', () async {
    final repo = await build();
    await repo.addDrawing(sourcePath: await drawing(), title: 'Local');

    final stale = GalleryAlbum(
        householdId: 'h', items: const [], updatedAt: DateTime(2026, 7, 1));
    await repo.applyRemote(stale);
    expect((await repo.watch().first).items, hasLength(1));

    final fresh = GalleryAlbum(
        householdId: 'h', items: const [], updatedAt: DateTime(2026, 7, 9));
    await repo.applyRemote(fresh);
    expect((await repo.watch().first).items, isEmpty);
  });

  test('republish publie l\'état local sans le modifier', () async {
    final repo = await build();
    await repo.addDrawing(sourcePath: await drawing(), title: 'A');
    realtime.published.clear();

    await repo.republish();

    final syncs =
        realtime.published.where((e) => e.type == GalleryEvents.sync).toList();
    expect(syncs, hasLength(1));
    final album = syncs.single.payload!['album'] as Map<String, dynamic>;
    expect(album['items'], hasLength(1));
  });
}
