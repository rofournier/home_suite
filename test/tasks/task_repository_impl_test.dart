import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/features/household/domain/household.dart';
import 'package:home_sweet_home/features/tasks/data/task_events.dart';
import 'package:home_sweet_home/features/tasks/data/task_local_datasource.dart';
import 'package:home_sweet_home/features/tasks/data/task_repository_impl.dart';
import 'package:home_sweet_home/features/household/domain/room.dart';
import 'package:home_sweet_home/features/tasks/domain/house_task.dart';
import 'package:home_sweet_home/features/tasks/domain/task_board.dart';
import 'package:home_sweet_home/features/tasks/domain/task_category.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shopping/fakes.dart';

class SeqTaskIds extends TaskIdGenerator {
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

  late FakeRealtimeService realtime;
  late TaskLocalDatasource datasource;

  Future<TaskRepositoryImpl> build() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    datasource = TaskLocalDatasource(prefs);
    realtime = FakeRealtimeService();
    return TaskRepositoryImpl(
      datasource: datasource,
      realtime: realtime,
      household: household,
      currentMember: me,
      idGenerator: SeqTaskIds(),
      clock: () => DateTime(2026, 7, 8),
    );
  }

  Future<TaskRepositoryImpl> withTask() async {
    final repo = await build();
    await repo.addTask(
      category: TaskCategory.vaisselle,
      severity: 2,
      room: Room.cuisine,
      x: 0.3,
      y: 0.6,
    );
    return repo;
  }

  test('addTask épingle, persiste, publie sync + added', () async {
    final repo = await withTask();

    final board = await repo.watch().first;
    final task = board.tasks.single;
    expect(task.category, TaskCategory.vaisselle);
    expect(task.room, Room.cuisine);
    expect(task.x, 0.3);
    expect(task.createdBy, 'me');
    expect(datasource.load('h')!.tasks, hasLength(1));

    expect(realtime.published.map((e) => e.type),
        containsAll([TaskEvents.sync, TaskEvents.added]));
    final added =
        realtime.published.singleWhere((e) => e.type == TaskEvents.added);
    expect(added.payload!['authorName'], 'Moi');
    expect((added.payload!['task'] as Map)['category'], 'vaisselle');
  });

  test('sévérité et coordonnées bornées', () async {
    final repo = await build();
    final task = await repo.addTask(
      category: TaskCategory.autre,
      severity: 9,
      room: Room.balcon,
      x: 1.4,
      y: -0.2,
    );
    expect(task.severity, 3);
    expect(task.x, 1.0);
    expect(task.y, 0.0);
  });

  test('completeTask → fantôme (jamais de suppression directe) + event',
      () async {
    final repo = await withTask();
    final id = (await repo.watch().first).tasks.single.id;
    realtime.published.clear();

    await repo.completeTask(id);

    final task = (await repo.watch().first).taskById(id)!;
    expect(task.awaitingValidation, isTrue);
    expect(task.completedBy, 'me');
    final completed =
        realtime.published.singleWhere((e) => e.type == TaskEvents.completed);
    expect(completed.payload!['byId'], 'me');
    expect((completed.payload!['task'] as Map)['id'], id);
  });

  test('reopenTask annule sa propre complétion (Undo, sans évènement)',
      () async {
    final repo = await withTask();
    final id = (await repo.watch().first).tasks.single.id;
    await repo.completeTask(id);
    realtime.published.clear();

    await repo.reopenTask(id);

    final task = (await repo.watch().first).taskById(id)!;
    expect(task.awaitingValidation, isFalse);
    expect(task.completedBy, isNull);
    expect(
        realtime.published.where((e) =>
            e.type == TaskEvents.rejected || e.type == TaskEvents.validated),
        isEmpty);
  });

  test('applyRemote ignore un état plus vieux (LWW)', () async {
    final repo = await withTask(); // stamp local 8/7

    final stale = TaskBoard(
        householdId: 'h', tasks: const [], updatedAt: DateTime(2026, 7, 1));
    await repo.applyRemote(stale);

    expect((await repo.watch().first).tasks, hasLength(1));
  });

  test('applyRemote applique un état plus récent sans publier', () async {
    final repo = await withTask();
    realtime.published.clear();

    final fresh = TaskBoard(
        householdId: 'h', tasks: const [], updatedAt: DateTime(2026, 7, 9));
    await repo.applyRemote(fresh);

    expect((await repo.watch().first).tasks, isEmpty);
    expect(realtime.published, isEmpty);
  });

  test('republish publie l\'état local', () async {
    final repo = await withTask();
    realtime.published.clear();

    await repo.republish();

    final syncs =
        realtime.published.where((e) => e.type == TaskEvents.sync).toList();
    expect(syncs, hasLength(1));
    final board = syncs.single.payload!['board'] as Map<String, dynamic>;
    expect(board['tasks'], hasLength(1));
  });

  /// Un fantôme complété par [completedBy] (créé par bob).
  HouseTask ghost(String id, {int severity = 3, String completedBy = 'bob'}) =>
      HouseTask(
        id: id,
        category: TaskCategory.vaisselle,
        severity: severity,
        room: Room.cuisine,
        x: 0.5,
        y: 0.5,
        createdBy: 'bob',
        createdAt: DateTime(2026, 7, 7),
        completedBy: completedBy,
        completedAt: DateTime(2026, 7, 8),
      );

  test('compléter ne crédite rien ; valider crédite le complétant', () async {
    final repo = await build();
    // Fantôme complété par bob → me (≠ complétant) peut valider.
    await repo.applyRemote(TaskBoard(
      householdId: 'h',
      tasks: [ghost('t1')],
      updatedAt: DateTime(2026, 7, 9),
    ));

    await repo.validateTask('t1');

    final board = await repo.watch().first;
    expect(board.taskById('t1'), isNull);
    expect(board.scoreOf('bob').points, 3); // le complétant, pas le validateur
    expect(board.scoreOf('bob').completedCount, 1);
    expect(board.scoreOf('me').points, 0);
    expect(realtime.published.map((e) => e.type),
        contains(TaskEvents.validated));
  });

  test('anti-triche : valider ou refuser sa propre complétion = no-op',
      () async {
    final repo = await build();
    await repo.applyRemote(TaskBoard(
      householdId: 'h',
      tasks: [ghost('t1', completedBy: 'me')],
      updatedAt: DateTime(2026, 7, 9),
    ));
    realtime.published.clear();

    await repo.validateTask('t1');
    await repo.rejectTask('t1');

    final board = await repo.watch().first;
    expect(board.taskById('t1')!.awaitingValidation, isTrue); // intacte
    expect(board.scoreOf('me').points, 0);
    expect(realtime.published, isEmpty);
  });

  test('refus par un autre → la tâche redevient active', () async {
    final repo = await build();
    await repo.applyRemote(TaskBoard(
      householdId: 'h',
      tasks: [ghost('t1', severity: 1)],
      updatedAt: DateTime(2026, 7, 9),
    ));
    realtime.published.clear();

    await repo.rejectTask('t1');

    final task = (await repo.watch().first).taskById('t1')!;
    expect(task.awaitingValidation, isFalse);
    expect(task.completedBy, isNull);
    expect(realtime.published.map((e) => e.type),
        contains(TaskEvents.rejected));
  });

  test('addTask compte la proposition au leaderboard', () async {
    final repo = await withTask();
    final score = (await repo.watch().first).scoreOf('me');
    expect(score.createdCount, 1);
    expect(score.points, 0); // proposer ne rapporte pas de points
  });
}
