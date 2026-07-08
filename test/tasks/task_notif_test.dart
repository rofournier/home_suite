import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/app/realtime_binding.dart';
import 'package:home_sweet_home/features/tasks/data/task_events.dart';
import 'package:home_sweet_home/features/tasks/domain/house_task.dart';
import 'package:home_sweet_home/features/household/domain/room.dart';
import 'package:home_sweet_home/features/tasks/domain/task_category.dart';
import 'package:home_sweet_home/features/tasks/presentation/task_notif.dart';

import '../shopping/fakes.dart';

HouseTask task({String by = 'bob'}) => HouseTask(
      id: 't1',
      category: TaskCategory.vaisselle,
      severity: 2,
      room: Room.cuisine,
      x: 0.5,
      y: 0.5,
      createdBy: by,
      createdAt: DateTime(2026, 7, 8),
    );

void main() {
  late FakeRealtimeService realtime;
  late ProviderContainer container;

  setUp(() {
    realtime = FakeRealtimeService();
    container = ProviderContainer(
      overrides: [realtimeServiceProvider.overrideWithValue(realtime)],
    );
    addTearDown(container.dispose);
    addTearDown(realtime.dispose);
    container.listen(taskNotifProvider, (_, _) {}); // garde le notifier vivant
  });

  Future<void> pump() => Future<void>.delayed(Duration.zero);

  test('ajout par un autre → bannière + badge hub', () async {
    realtime.emit(taskAddedEvent(authorName: 'Bob', task: task()));
    await pump();

    final state = container.read(taskNotifProvider);
    expect(state.banner, isNotNull);
    expect(state.banner!.kind, TaskBannerKind.added);
    expect(state.banner!.categoryLabel, 'Vaisselle');
    expect(state.banner!.roomLabel, 'Cuisine');
    expect(state.hubUnseen, 1);
  });

  test('complétion par un autre → bannière complétion', () async {
    realtime.emit(taskCompletedEvent(
        authorName: 'Bob', byId: 'bob', task: task(by: 'me')));
    await pump();

    final state = container.read(taskNotifProvider);
    expect(state.banner!.kind, TaskBannerKind.completed);
    expect(state.banner!.authorName, 'Bob');
  });

  test('validation et refus par un autre → bannières dédiées', () async {
    realtime.emit(taskValidatedEvent(
        authorName: 'Bob', byId: 'bob', task: task(by: 'bob')));
    await pump();
    expect(container.read(taskNotifProvider).banner!.kind,
        TaskBannerKind.validated);

    realtime.emit(taskRejectedEvent(
        authorName: 'Bob', byId: 'bob', task: task(by: 'bob')));
    await pump();
    expect(container.read(taskNotifProvider).banner!.kind,
        TaskBannerKind.rejected);
    expect(container.read(taskNotifProvider).hubUnseen, 2);
  });

  test('mes propres évènements sont ignorés (pas d\'auto-notif)', () async {
    // Le membre courant par défaut (fallback solo) a l'id 'me'.
    realtime.emit(taskAddedEvent(authorName: 'Moi', task: task(by: 'me')));
    realtime.emit(taskCompletedEvent(
        authorName: 'Moi', byId: 'me', task: task(by: 'bob')));
    await pump();

    final state = container.read(taskNotifProvider);
    expect(state.banner, isNull);
    expect(state.hubUnseen, 0);
  });

  test('resetHubUnseen remet le badge à zéro', () async {
    realtime.emit(taskAddedEvent(authorName: 'Bob', task: task()));
    await pump();
    container.read(taskNotifProvider.notifier).resetHubUnseen();
    expect(container.read(taskNotifProvider).hubUnseen, 0);
  });
}
