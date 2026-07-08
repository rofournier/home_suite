import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/realtime_binding.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../household/presentation/household_providers.dart';
import '../data/task_events.dart';
import '../domain/house_task.dart';

/// Nature de l'évènement affiché par la bannière.
enum TaskBannerKind { added, completed, validated, rejected }

/// Une notif in-app éphémère de tâche : « Marie → Vaisselle (Cuisine) » à
/// l'ajout, « Suleyman a fait : Vaisselle » à la complétion, etc.
class TaskBanner {
  const TaskBanner({
    required this.authorName,
    required this.categoryLabel,
    required this.categoryEmoji,
    required this.roomLabel,
    required this.kind,
  });

  final String authorName;
  final String categoryLabel;
  final String categoryEmoji;
  final String roomLabel;
  final TaskBannerKind kind;
}

class TaskNotifState {
  const TaskNotifState({this.banner, this.hubUnseen = 0});

  final TaskBanner? banner;
  final int hubUnseen;

  TaskNotifState copyWith({
    TaskBanner? banner,
    bool clearBanner = false,
    int? hubUnseen,
  }) =>
      TaskNotifState(
        banner: clearBanner ? null : (banner ?? this.banner),
        hubUnseen: hubUnseen ?? this.hubUnseen,
      );
}

/// Écoute les évènements temps réel de tâches et en dérive bannière + badge
/// hub. Ignore les évènements émis par soi-même.
class TaskNotifNotifier extends Notifier<TaskNotifState> {
  @override
  TaskNotifState build() {
    final me = ref.watch(currentMemberProvider).id;
    final sub = ref.watch(realtimeServiceProvider).events.listen(
          (event) => _onEvent(event, me),
        );
    ref.onDispose(sub.cancel);
    return const TaskNotifState();
  }

  void _onEvent(RealtimeEvent event, String meId) {
    final kind = switch (event.type) {
      TaskEvents.added => TaskBannerKind.added,
      TaskEvents.completed => TaskBannerKind.completed,
      TaskEvents.validated => TaskBannerKind.validated,
      TaskEvents.rejected => TaskBannerKind.rejected,
      _ => null,
    };
    if (kind == null) return;
    final payload = event.payload;
    final taskJson = payload?['task'] as Map<String, dynamic>?;
    if (payload == null || taskJson == null) return;
    // Pas d'auto-notif : l'acteur est `byId`, ou l'auteur du pin à l'ajout.
    final actorId = kind == TaskBannerKind.added
        ? taskJson['createdBy'] as String?
        : payload['byId'] as String?;
    if (actorId == meId) return;

    final task = HouseTask.fromJson(taskJson);
    state = state.copyWith(
      banner: TaskBanner(
        authorName: payload['authorName'] as String? ?? 'Quelqu\'un',
        categoryLabel: task.category.label,
        categoryEmoji: task.category.emoji,
        roomLabel: task.room.label,
        kind: kind,
      ),
      hubUnseen: state.hubUnseen + 1,
    );
  }

  void dismissBanner() => state = state.copyWith(clearBanner: true);

  /// Plan ouvert depuis le HUB → reset du compteur.
  void resetHubUnseen() {
    if (state.hubUnseen == 0) return;
    state = state.copyWith(hubUnseen: 0);
  }
}

final taskNotifProvider =
    NotifierProvider<TaskNotifNotifier, TaskNotifState>(TaskNotifNotifier.new);

/// Compteur non-vus exposé au HUB (badge sur le hotspot Plan).
final hubTaskUnseenProvider =
    Provider<int>((ref) => ref.watch(taskNotifProvider).hubUnseen);
