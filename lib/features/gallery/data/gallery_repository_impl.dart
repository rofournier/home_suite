import 'dart:async';

import '../../../core/files/local_image_store.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../documents/data/document_remote_datasource.dart';
import '../../household/domain/household.dart';
import '../domain/gallery_album.dart';
import '../domain/gallery_item.dart';
import '../domain/gallery_repository.dart';
import 'gallery_events.dart';
import 'gallery_local_datasource.dart';

/// Génère un id unique sans dépendance externe (timestamp + compteur).
class GalleryIdGenerator {
  int _counter = 0;
  String next() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-${_counter++}';
}

/// Impl locale de [GalleryRepository]. Même mécanique que documents : copie
/// locale, upload best-effort, sync métadonnées complètes (LWW), republish.
class GalleryRepositoryImpl implements GalleryRepository {
  GalleryRepositoryImpl({
    required this._datasource,
    required this._imageStore,
    required this._realtime,
    required this._household,
    required this._currentMember,
    this.remote,
    GalleryIdGenerator? idGenerator,
    DateTime Function()? clock,
  })  : _ids = idGenerator ?? GalleryIdGenerator(),
        _now = clock ?? DateTime.now;

  final GalleryLocalDatasource _datasource;
  final LocalImageStore _imageStore;
  final RealtimeService _realtime;
  final Household _household;
  final Member _currentMember;

  /// Upload des binaires (null = pas de serveur, ex. tests/déconnecté).
  final DocumentRemoteDatasource? remote;
  final GalleryIdGenerator _ids;
  final DateTime Function() _now;

  final _controller = StreamController<GalleryAlbum>.broadcast();
  late GalleryAlbum _album;
  bool _initialized = false;

  @override
  Stream<GalleryAlbum> watch() async* {
    await _ready();
    yield _album;
    yield* _controller.stream;
  }

  Future<void> _ready() async {
    if (_initialized) return;
    _initialized = true;
    _album = _datasource.load(_household.id) ??
        GalleryAlbum(householdId: _household.id);
  }

  Future<void> _commit(GalleryAlbum next) async {
    _album = next.copyWith(updatedAt: _now());
    await _datasource.save(_album);
    _controller.add(_album);
    await _realtime.publish(gallerySyncEvent(_album.toJson()));
  }

  @override
  Future<GalleryItem> addDrawing({
    required String sourcePath,
    required String title,
  }) async {
    await _ready();
    final id = _ids.next();
    final storedPath =
        await _imageStore.persist(sourcePath: sourcePath, id: id);
    final fileId = await remote?.upload(storedPath);
    final item = GalleryItem(
      id: id,
      title: title,
      imagePath: storedPath,
      fileId: fileId,
      createdBy: _currentMember.id,
      createdAt: _now(),
    );
    await _commit(_album.addItem(item));
    return item;
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await _ready();
    final item = _album.itemById(itemId);
    if (item == null) return;
    await _commit(_album.removeItem(itemId));
    await _imageStore.delete(item.imagePath);
  }

  @override
  Future<void> applyRemote(GalleryAlbum album) async {
    await _ready();
    // LWW : ignore un état plus vieux que le nôtre (modifs hors ligne).
    final local = _album.updatedAt;
    final incoming = album.updatedAt;
    if (local != null && (incoming == null || incoming.isBefore(local))) {
      return;
    }
    _album = album;
    await _datasource.save(album);
    _controller.add(album);
  }

  @override
  Future<void> republish() async {
    await _ready();
    await _realtime.publish(gallerySyncEvent(_album.toJson()));
  }

  void dispose() => _controller.close();
}
