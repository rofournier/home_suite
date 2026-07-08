import '../../household/domain/room.dart';
import 'house_task.dart';
import 'task_board.dart';
import 'task_category.dart';

/// Accès aux tâches du plan d'une maison. Local = source de vérité
/// (offline-first) ; l'impl synchronise l'état complet via `RealtimeService`
/// et publie les évènements de notif (ajout / complétion / validation).
abstract interface class TaskRepository {
  Stream<TaskBoard> watch();

  /// Épingle une tâche à la position normalisée ([x], [y]) ∈ [0..1].
  Future<HouseTask> addTask({
    required TaskCategory category,
    required int severity,
    required Room room,
    required double x,
    required double y,
  });

  /// Marque la tâche « faite » → fantôme en attente de validation par un
  /// autre membre (les points tomberont à la validation). Anti-triche :
  /// personne ne fait disparaître une tâche tout seul.
  Future<void> completeTask(String taskId);

  /// Validation par un membre **autre que le complétant** : la tâche
  /// disparaît, le complétant marque ses points. No-op si le membre courant
  /// est le complétant.
  Future<void> validateTask(String taskId);

  /// Refus (membre autre que le complétant) : la tâche redevient active.
  Future<void> rejectTask(String taskId);

  /// Ré-active un fantôme sans évènement (Annuler sa propre complétion).
  Future<void> reopenTask(String taskId);

  /// Applique un état reçu (temps réel). Ignoré si plus vieux (LWW).
  Future<void> applyRemote(TaskBoard board);

  /// Re-publie l'état local (réconciliation à la (re)connexion).
  Future<void> republish();
}
