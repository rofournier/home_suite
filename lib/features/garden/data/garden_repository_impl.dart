import 'dart:async';

import '../../../core/files/local_image_store.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../documents/data/document_remote_datasource.dart';
import '../../household/domain/household.dart';
import '../../household/domain/room.dart';
import '../domain/garden.dart';
import '../domain/garden_repository.dart';
import '../domain/plant.dart';
import 'garden_events.dart';
import 'garden_local_datasource.dart';

/// Génère un id unique sans dépendance externe (timestamp + compteur).
class GardenIdGenerator {
  int _counter = 0;
  String next() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-${_counter++}';
}

/// Impl locale de [GardenRepository]. Même mécanique que les autres agrégats :
/// état en mémoire (miroir prefs), transformations pures, LWW, republish.
class GardenRepositoryImpl implements GardenRepository {
  GardenRepositoryImpl({
    required this._datasource,
    required this._imageStore,
    required this._realtime,
    required this._household,
    required this._currentMember,
    this.remote,
    GardenIdGenerator? idGenerator,
    DateTime Function()? clock,
  })  : _ids = idGenerator ?? GardenIdGenerator(),
        _now = clock ?? DateTime.now;

  final GardenLocalDatasource _datasource;
  final LocalImageStore _imageStore;
  final RealtimeService _realtime;
  final Household _household;
  final Member _currentMember;

  /// Upload des photos (null = pas de serveur, ex. tests/déconnecté).
  final DocumentRemoteDatasource? remote;
  final GardenIdGenerator _ids;
  final DateTime Function() _now;

  final _controller = StreamController<Garden>.broadcast();
  late Garden _garden;
  bool _initialized = false;

  @override
  Stream<Garden> watch() async* {
    await _ready();
    yield _garden;
    yield* _controller.stream;
  }

  Future<void> _ready() async {
    if (_initialized) return;
    _initialized = true;
    _garden =
        _datasource.load(_household.id) ?? Garden(householdId: _household.id);
  }

  Future<void> _commit(Garden next) async {
    _garden = next.copyWith(updatedAt: _now());
    await _datasource.save(_garden);
    _controller.add(_garden);
    await _realtime.publish(gardenSyncEvent(_garden.toJson()));
  }

  Future<({String path, String? fileId})?> _storePhoto(
      String? sourcePath, String id) async {
    if (sourcePath == null) return null;
    final path = await _imageStore.persist(sourcePath: sourcePath, id: id);
    final fileId = await remote?.upload(path);
    return (path: path, fileId: fileId);
  }

  @override
  Future<Plant> addPlant({
    required String name,
    required Room room,
    required int waterEveryDays,
    int? feedEveryDays,
    String note = '',
    String? photoSourcePath,
  }) async {
    await _ready();
    final id = _ids.next();
    final photo = await _storePhoto(photoSourcePath, id);
    final plant = Plant(
      id: id,
      name: name,
      room: room,
      photoPath: photo?.path,
      fileId: photo?.fileId,
      waterEveryDays: waterEveryDays.clamp(1, 60),
      feedEveryDays: feedEveryDays?.clamp(1, 120),
      note: note,
      createdBy: _currentMember.id,
      createdAt: _now(),
    );
    await _commit(_garden.addPlant(plant));
    return plant;
  }

  @override
  Future<void> updatePlant(Plant plant, {String? photoSourcePath}) async {
    await _ready();
    var next = plant;
    if (photoSourcePath != null) {
      final old = _garden.plantById(plant.id)?.photoPath;
      // Nouveau fichier suffixé (sinon même chemin → cache d'image périmé).
      final photo =
          await _storePhoto(photoSourcePath, '${plant.id}-${_ids.next()}');
      next = next.copyWith(photoPath: photo?.path, fileId: photo?.fileId);
      if (old != null) await _imageStore.delete(old);
    }
    await _commit(_garden.replacePlant(next));
  }

  @override
  Future<void> deletePlant(String plantId) async {
    await _ready();
    final plant = _garden.plantById(plantId);
    if (plant == null) return;
    await _commit(_garden.removePlant(plantId));
    if (plant.photoPath != null) await _imageStore.delete(plant.photoPath!);
  }

  @override
  Future<Plant?> waterPlant(String plantId) async {
    await _ready();
    final previous = _garden.plantById(plantId);
    if (previous == null) return null;
    await _commit(
        _garden.waterPlant(plantId, by: _currentMember.id, at: _now()));
    return previous;
  }

  @override
  Future<Plant?> feedPlant(String plantId) async {
    await _ready();
    final previous = _garden.plantById(plantId);
    if (previous == null) return null;
    await _commit(
        _garden.feedPlant(plantId, by: _currentMember.id, at: _now()));
    return previous;
  }

  @override
  Future<List<Plant>> waterRoom(Room room) async {
    await _ready();
    final previous = _garden.plantsIn(room);
    if (previous.isEmpty) return const [];
    await _commit(_garden.waterRoom(room, by: _currentMember.id, at: _now()));
    return previous;
  }

  @override
  Future<void> restorePlants(List<Plant> previous) async {
    await _ready();
    var garden = _garden;
    for (final plant in previous) {
      garden = garden.replacePlant(plant);
    }
    await _commit(garden);
  }

  @override
  Future<void> applyRemote(Garden garden) async {
    await _ready();
    // LWW : ignore un état plus vieux que le nôtre (modifs hors ligne).
    final local = _garden.updatedAt;
    final incoming = garden.updatedAt;
    if (local != null && (incoming == null || incoming.isBefore(local))) {
      return;
    }
    _garden = garden;
    await _datasource.save(garden);
    _controller.add(garden);
  }

  @override
  Future<void> republish() async {
    await _ready();
    await _realtime.publish(gardenSyncEvent(_garden.toJson()));
  }

  void dispose() => _controller.close();
}
