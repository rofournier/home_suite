import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/realtime_binding.dart';
import '../../../core/persistence/shared_preferences_provider.dart';
import '../../household/presentation/household_providers.dart';
import '../data/task_events.dart';
import '../data/task_local_datasource.dart';
import '../data/task_repository_impl.dart';
import '../domain/task_board.dart';
import '../domain/task_repository.dart';

final _datasourceProvider = Provider<TaskLocalDatasource>(
  (ref) => TaskLocalDatasource(ref.watch(sharedPreferencesProvider)),
);

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final repository = TaskRepositoryImpl(
    datasource: ref.watch(_datasourceProvider),
    realtime: ref.watch(realtimeServiceProvider),
    household: ref.watch(householdProvider),
    currentMember: ref.watch(currentMemberProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

/// Board courant (tâches épinglées). Loading / error / data.
final taskBoardProvider = StreamProvider<TaskBoard>(
  (ref) => ref.watch(taskRepositoryProvider).watch(),
);

/// Applique les états reçus des autres membres et re-publie le local à chaque
/// (re)connexion. Observé par le hub + l'écran plan.
final taskSyncProvider = Provider<void>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  final realtime = ref.watch(realtimeServiceProvider);
  final events = realtime.events.listen((event) {
    if (event.type != TaskEvents.sync) return;
    final board = event.payload?['board'];
    if (board is Map<String, dynamic>) {
      repository.applyRemote(TaskBoard.fromJson(board));
    }
  });
  final connects = realtime.onConnect.listen((_) => repository.republish());
  ref.onDispose(() {
    events.cancel();
    connects.cancel();
  });
});
