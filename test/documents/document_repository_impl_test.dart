import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/features/documents/data/document_events.dart';
import 'package:home_sweet_home/core/files/local_image_store.dart';
import 'package:home_sweet_home/features/documents/data/document_local_datasource.dart';
import 'package:home_sweet_home/features/documents/data/document_repository_impl.dart';
import 'package:home_sweet_home/features/documents/domain/document_library.dart';
import 'package:home_sweet_home/features/household/domain/household.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../shopping/fakes.dart';

class SeqDocIds extends DocumentIdGenerator {
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
  late DocumentLocalDatasource datasource;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hsh_docs_test');
  });
  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  Future<DocumentRepositoryImpl> build() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    datasource = DocumentLocalDatasource(prefs);
    realtime = FakeRealtimeService();
    return DocumentRepositoryImpl(
      datasource: datasource,
      imageStore: LocalImageStore(subdir: 'documents', baseDir: () async => tempDir),
      realtime: realtime,
      household: household,
      currentMember: me,
      idGenerator: SeqDocIds(),
      clock: () => DateTime(2026, 7, 8),
      seedTabs: const ['Factures', 'Photos'],
    );
  }

  Future<String> source(String name) async {
    final f = File(p.join(tempDir.path, 'src_$name'));
    await f.writeAsBytes([1, 2, 3]);
    return f.path;
  }

  test('premier flux = onglets seedés et persistés', () async {
    final repo = await build();
    final lib = await repo.watch().first;
    expect(lib.tabs.map((t) => t.name), ['Factures', 'Photos']);
    expect(datasource.load('h')!.tabs, hasLength(2));
  });

  test('addDocument copie l\'image, persiste et remplit les métadonnées',
      () async {
    final repo = await build();
    final tabId = (await repo.watch().first).tabs.first.id;

    final doc = await repo.addDocument(tabId,
        sourcePath: await source('a.jpg'), title: 'Facture EDF');

    expect(doc.title, 'Facture EDF');
    expect(doc.createdBy, 'me');
    expect(doc.tabId, tabId);
    // Fichier copié dans le stockage de l'app (nommé par id).
    expect(File(doc.imagePath).existsSync(), isTrue);
    expect(p.basename(doc.imagePath), startsWith(doc.id));
    // Persisté.
    expect(datasource.load('h')!.tabs.first.documents.single.title,
        'Facture EDF');
  });

  test('deleteDocument retire l\'entrée et supprime le fichier', () async {
    final repo = await build();
    final tabId = (await repo.watch().first).tabs.first.id;
    final doc = await repo.addDocument(tabId,
        sourcePath: await source('a.jpg'), title: 'A');
    expect(File(doc.imagePath).existsSync(), isTrue);

    await repo.deleteDocument(tabId, doc.id);

    expect((await repo.watch().first).tabs.first.documents, isEmpty);
    expect(File(doc.imagePath).existsSync(), isFalse);
  });

  test('deleteTab supprime les fichiers de ses documents', () async {
    final repo = await build();
    final tabId = (await repo.watch().first).tabs.first.id;
    final doc = await repo.addDocument(tabId,
        sourcePath: await source('a.jpg'), title: 'A');

    await repo.deleteTab(tabId);

    expect((await repo.watch().first).tabs.any((t) => t.id == tabId), isFalse);
    expect(File(doc.imagePath).existsSync(), isFalse);
  });

  test('renameDocument met à jour le titre', () async {
    final repo = await build();
    final tabId = (await repo.watch().first).tabs.first.id;
    final doc = await repo.addDocument(tabId,
        sourcePath: await source('a.jpg'), title: 'Ancien');

    await repo.renameDocument(tabId, doc.id, 'Nouveau');
    expect((await repo.watch().first).tabs.first.documents.single.title,
        'Nouveau');
  });

  test('applyRemote remplace la bibliothèque sans publier', () async {
    final repo = await build();
    await repo.watch().first; // seed
    realtime.published.clear();

    final remote = DocumentLibrary(
        householdId: 'h', tabs: const [], updatedAt: DateTime(2026, 7, 9));
    await repo.applyRemote(remote);

    expect((await repo.watch().first).tabs, isEmpty);
    expect(realtime.published, isEmpty);
  });

  test('applyRemote ignore un état plus vieux (LWW)', () async {
    final repo = await build();
    final tabId = (await repo.watch().first).tabs.first.id;
    await repo.renameTab(tabId, 'Hors ligne'); // stamp local 8/7

    final stale = DocumentLibrary(
        householdId: 'h', tabs: const [], updatedAt: DateTime(2026, 7, 1));
    await repo.applyRemote(stale);

    expect((await repo.watch().first).tabs.first.name, 'Hors ligne');
  });

  test('republish publie l\'état local', () async {
    final repo = await build();
    await repo.watch().first;
    realtime.published.clear();

    await repo.republish();
    expect(realtime.published.where((e) => e.type == DocumentEvents.sync),
        hasLength(1));
  });

  test('chaque mutation publie une sync portant les métadonnées complètes',
      () async {
    final repo = await build();
    final tabId = (await repo.watch().first).tabs.first.id;
    realtime.published.clear();

    await repo.addDocument(tabId,
        sourcePath: await source('a.jpg'), title: 'A');

    final syncs =
        realtime.published.where((e) => e.type == DocumentEvents.sync).toList();
    expect(syncs, hasLength(1));
    final library = syncs.single.payload!['library'] as Map<String, dynamic>;
    final docs = (library['tabs'] as List).first['documents'] as List;
    expect((docs.single as Map)['title'], 'A');
  });

  test('sans serveur (remote null), le document reste local : fileId null',
      () async {
    final repo = await build();
    final tabId = (await repo.watch().first).tabs.first.id;
    final doc = await repo.addDocument(tabId,
        sourcePath: await source('a.jpg'), title: 'A');
    expect(doc.fileId, isNull);
    expect(File(doc.imagePath).existsSync(), isTrue); // copie locale intacte
  });
}
