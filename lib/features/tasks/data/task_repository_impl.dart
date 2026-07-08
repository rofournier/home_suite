import 'dart:async';

import '../../../core/realtime/realtime_service.dart';
import '../../household/domain/household.dart';
import '../../household/domain/room.dart';
import '../domain/house_task.dart';
import '../domain/scoring.dart';
import '../domain/task_board.dart';
import '../domain/task_category.dart';
import '../domain/task_repository.dart';
import 'task_events.dart';
import 'task_local_datasource.dart';

/// Génère un id unique sans dépendance externe (timestamp + compteur).
class TaskIdGenerator {
  int _counter = 0;
  String next() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-${_counter++}';
}

/// Impl locale de [TaskRepository]. Même mécanique que courses/documents :
/// board en mémoire (miroir prefs), transformations pures, LWW, republish.
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({
    required this._datasource,
    required this._realtime,
    required this._household,
    required this._currentMember,
    TaskIdGenerator? idGenerator,
    DateTime Function()? clock,
  })  : _ids = idGenerator ?? TaskIdGenerator(),
        _now = clock ?? DateTime.now;

  final TaskLocalDatasource _datasource;
  final RealtimeService _realtime;
  final Household _household;
  final Member _currentMember;
  final TaskIdGenerator _ids;
  final DateTime Function() _now;

  final _controller = StreamController<TaskBoard>.broadcast();
  late TaskBoard _board;
  bool _initialized = false;

  @override
  Stream<TaskBoard> watch() async* {
    await _ready();
    yield _board;
    yield* _controller.stream;
  }

  Future<void> _ready() async {
    if (_initialized) return;
    _initialized = true;
    _board = _datasource.load(_household.id) ??
        TaskBoard(householdId: _household.id);
  }

  Future<void> _commit(TaskBoard next) async {
    _board = next.copyWith(updatedAt: _now());
    await _datasource.save(_board);
    _controller.add(_board);
    await _realtime.publish(taskSyncEvent(_board.toJson()));
  }

  @override
  Future<HouseTask> addTask({
    required TaskCategory category,
    required int severity,
    required Room room,
    required double x,
    required double y,
  }) async {
    await _ready();
    final task = HouseTask(
      id: _ids.next(),
      category: category,
      severity: severity.clamp(1, 3),
      room: room,
      x: x.clamp(0, 1),
      y: y.clamp(0, 1),
      createdBy: _currentMember.id,
      createdAt: _now(),
    );
    await _commit(
        _board.addTask(task).creditCreation(_currentMember.id));
    await _realtime.publish(
        taskAddedEvent(authorName: _currentMember.displayName, task: task));
    return task;
  }

  @override
  Future<void> completeTask(String taskId) async {
    await _ready();
    final task = _board.taskById(taskId);
    if (task == null || task.awaitingValidation) return;
    // Toujours fantôme : la disparition (et les points) attendent la
    // validation d'un AUTRE membre — personne ne s'auto-attribue de points.
    await _commit(
        _board.markCompleted(taskId, by: _currentMember.id, at: _now()));
    await _realtime.publish(taskCompletedEvent(
      authorName: _currentMember.displayName,
      byId: _currentMember.id,
      task: task,
    ));
  }

  @override
  Future<void> validateTask(String taskId) async {
    await _ready();
    final task = _board.taskById(taskId);
    if (task == null || !task.awaitingValidation) return;
    // Anti-triche : on ne valide pas sa propre complétion.
    if (task.completedBy == _currentMember.id) return;
    await _commit(_board
        .removeTask(taskId)
        .creditCompletion(task.completedBy!, pointsForSeverity(task.severity)));
    await _realtime.publish(taskValidatedEvent(
      authorName: _currentMember.displayName,
      byId: _currentMember.id,
      task: task,
    ));
  }

  @override
  Future<void> rejectTask(String taskId) async {
    await _ready();
    final task = _board.taskById(taskId);
    if (task == null || !task.awaitingValidation) return;
    // Même règle que la validation : le complétant ne se juge pas lui-même
    // (lui dispose d'Annuler → reopenTask).
    if (task.completedBy == _currentMember.id) return;
    await _commit(_board.reopenTask(taskId));
    await _realtime.publish(taskRejectedEvent(
      authorName: _currentMember.displayName,
      byId: _currentMember.id,
      task: task,
    ));
  }

  @override
  Future<void> reopenTask(String taskId) async {
    await _ready();
    await _commit(_board.reopenTask(taskId));
  }

  @override
  Future<void> applyRemote(TaskBoard board) async {
    await _ready();
    // LWW : ignore un état plus vieux que le nôtre (modifs hors ligne).
    final local = _board.updatedAt;
    final incoming = board.updatedAt;
    if (local != null && (incoming == null || incoming.isBefore(local))) {
      return;
    }
    _board = board;
    await _datasource.save(board);
    _controller.add(board);
  }

  @override
  Future<void> republish() async {
    await _ready();
    await _realtime.publish(taskSyncEvent(_board.toJson()));
  }

  void dispose() => _controller.close();
}
