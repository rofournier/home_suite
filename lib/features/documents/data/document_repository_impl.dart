import 'dart:async';

import '../../../core/realtime/realtime_service.dart';
import '../../household/domain/household.dart';
import '../domain/document.dart';
import '../domain/document_library.dart';
import '../domain/document_repository.dart';
import '../domain/document_tab.dart';
import 'document_events.dart';
import '../../../core/files/local_image_store.dart';
import 'document_local_datasource.dart';
import 'document_remote_datasource.dart';

/// Génère un id unique sans dépendance externe (timestamp + compteur).
class DocumentIdGenerator {
  int _counter = 0;
  String next() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-${_counter++}';
}

/// Impl locale de [DocumentRepository]. Tient la bibliothèque en mémoire
/// (miroir de `shared_preferences`), applique des transformations pures,
/// persiste, émet sur le flux, et publie un ping temps réel (server-ready).
class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl({
    required this._datasource,
    required this._imageStore,
    required this._realtime,
    required this._household,
    required this._currentMember,
    this.remote,
    DocumentIdGenerator? idGenerator,
    DateTime Function()? clock,
    this._seedTabs = const ['Factures', 'Photos', 'Perso'],
  })  : _ids = idGenerator ?? DocumentIdGenerator(),
        _now = clock ?? DateTime.now;

  final DocumentLocalDatasource _datasource;
  final LocalImageStore _imageStore;
  final RealtimeService _realtime;
  final Household _household;
  final Member _currentMember;

  /// Upload des binaires (null = pas de serveur, ex. tests/déconnecté).
  final DocumentRemoteDatasource? remote;
  final DocumentIdGenerator _ids;
  final DateTime Function() _now;
  final List<String> _seedTabs;

  final _controller = StreamController<DocumentLibrary>.broadcast();
  late DocumentLibrary _library;
  bool _initialized = false;

  @override
  Stream<DocumentLibrary> watch() async* {
    await _ready();
    yield _library;
    yield* _controller.stream;
  }

  Future<void> _ready() async {
    if (_initialized) return;
    final loaded = _datasource.load(_household.id);
    _initialized = true;
    if (loaded != null) {
      _library = loaded;
      return;
    }
    _library = _seed();
    await _datasource.save(_library);
  }

  DocumentLibrary _seed() => DocumentLibrary(
        householdId: _household.id,
        tabs: [
          for (final name in _seedTabs)
            DocumentTab(id: _ids.next(), name: name),
        ],
      );

  Future<void> _commit(DocumentLibrary next) async {
    _library = next.copyWith(updatedAt: _now());
    await _datasource.save(_library);
    _controller.add(_library);
    // Sync temps réel : métadonnées complètes (les binaires passent par HTTP).
    await _realtime.publish(documentSyncEvent(_library.toJson()));
  }

  DocumentTab _requireTab(String tabId) {
    final tab = _library.tabById(tabId);
    if (tab == null) throw StateError('Onglet introuvable : $tabId');
    return tab;
  }

  @override
  Future<String> addTab(String name) async {
    await _ready();
    final id = _ids.next();
    await _commit(_library.addTab(DocumentTab(id: id, name: name)));
    return id;
  }

  @override
  Future<void> renameTab(String tabId, String name) async {
    await _ready();
    await _commit(_library.renameTab(tabId, name));
  }

  @override
  Future<void> deleteTab(String tabId) async {
    await _ready();
    final tab = _library.tabById(tabId);
    await _commit(_library.deleteTab(tabId));
    // Nettoie les fichiers images de l'onglet supprimé.
    for (final doc in tab?.documents ?? const <Document>[]) {
      await _imageStore.delete(doc.imagePath);
    }
  }

  @override
  Future<void> reorderTabs(List<String> orderedIds) async {
    await _ready();
    await _commit(_library.reorderTabs(orderedIds));
  }

  @override
  Future<Document> addDocument(
    String tabId, {
    required String sourcePath,
    required String title,
  }) async {
    await _ready();
    final tab = _requireTab(tabId);
    final id = _ids.next();
    final storedPath =
        await _imageStore.persist(sourcePath: sourcePath, id: id);
    // Upload best-effort AVANT le commit : la sync publiée porte directement
    // le fileId et les autres membres peuvent télécharger l'image. En cas
    // d'échec (offline), le doc reste local (fileId null), sans erreur.
    final fileId = await remote?.upload(storedPath);
    final doc = Document(
      id: id,
      tabId: tabId,
      title: title,
      imagePath: storedPath,
      fileId: fileId,
      createdBy: _currentMember.id,
      createdAt: _now(),
    );
    await _commit(_library.replaceTab(tab.addDocument(doc)));
    return doc;
  }

  @override
  Future<void> renameDocument(String tabId, String docId, String title) async {
    await _ready();
    final tab = _requireTab(tabId);
    await _commit(_library.replaceTab(tab.renameDocument(docId, title)));
  }

  @override
  Future<void> deleteDocument(String tabId, String docId) async {
    await _ready();
    final tab = _requireTab(tabId);
    final doc = tab.documents.firstWhere(
      (d) => d.id == docId,
      orElse: () => throw StateError('Document introuvable : $docId'),
    );
    await _commit(_library.replaceTab(tab.deleteDocument(docId)));
    await _imageStore.delete(doc.imagePath);
  }

  @override
  Future<void> applyRemote(DocumentLibrary library) async {
    await _ready();
    // LWW : ignore un état plus vieux que le nôtre (modifs hors ligne).
    final local = _library.updatedAt;
    final incoming = library.updatedAt;
    if (local != null && (incoming == null || incoming.isBefore(local))) {
      return;
    }
    _library = library;
    await _datasource.save(library);
    _controller.add(library);
  }

  @override
  Future<void> republish() async {
    await _ready();
    await _realtime.publish(documentSyncEvent(_library.toJson()));
  }

  void dispose() => _controller.close();
}
