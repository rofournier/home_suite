import '../../../core/realtime/realtime_service.dart';
import '../domain/house_task.dart';

/// Évènements temps réel des tâches. `sync` porte l'état complet du board ;
/// `added`/`completed` déclenchent les notifs chez les autres membres.
abstract final class TaskEvents {
  static const sync = 'task.sync';
  static const added = 'task.added';
  static const completed = 'task.completed';
  static const validated = 'task.validated';
  static const rejected = 'task.rejected';
}

RealtimeEvent taskSyncEvent(Map<String, dynamic> boardJson) =>
    RealtimeEvent(type: TaskEvents.sync, payload: {'board': boardJson});

/// Le payload porte de quoi afficher « Marie → Vaisselle (Cuisine) » sans
/// relookup, plus la tâche complète (dont `createdBy` pour ignorer l'auto-notif).
RealtimeEvent taskAddedEvent({
  required String authorName,
  required HouseTask task,
}) =>
    RealtimeEvent(
      type: TaskEvents.added,
      payload: {'authorName': authorName, 'task': task.toJson()},
    );

/// `byId` = membre qui a terminé la tâche (≠ auteur du pin, possiblement).
RealtimeEvent taskCompletedEvent({
  required String authorName,
  required String byId,
  required HouseTask task,
}) =>
    RealtimeEvent(
      type: TaskEvents.completed,
      payload: {
        'authorName': authorName,
        'byId': byId,
        'task': task.toJson(),
      },
    );

/// Le créateur a validé la complétion (la tâche disparaît, points crédités).
RealtimeEvent taskValidatedEvent({
  required String authorName,
  required String byId,
  required HouseTask task,
}) =>
    RealtimeEvent(
      type: TaskEvents.validated,
      payload: {
        'authorName': authorName,
        'byId': byId,
        'task': task.toJson(),
      },
    );

/// Le créateur a refusé la complétion (la tâche redevient active).
RealtimeEvent taskRejectedEvent({
  required String authorName,
  required String byId,
  required HouseTask task,
}) =>
    RealtimeEvent(
      type: TaskEvents.rejected,
      payload: {
        'authorName': authorName,
        'byId': byId,
        'task': task.toJson(),
      },
    );
