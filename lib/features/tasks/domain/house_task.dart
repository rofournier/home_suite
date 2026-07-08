import 'package:freezed_annotation/freezed_annotation.dart';

import '../../household/domain/room.dart';
import 'task_category.dart';

part 'house_task.freezed.dart';
part 'house_task.g.dart';

/// Une tâche épinglée sur le plan. `x`/`y` = position normalisée (0-1)
/// relative à l'image du plan → identique sur tous les écrans.
/// `severity` ∈ [1..3] (1 = peut attendre, 3 = urgent).
///
/// Anti-triche : marquer une tâche « faite » la passe en **fantôme**
/// (`completedBy`/`completedAt` remplis) ; seule la validation par un membre
/// **autre que le complétant** la fait disparaître (et crédite les points).
/// Sérialisable = DTO serveur (sync temps réel).
@freezed
abstract class HouseTask with _$HouseTask {
  const factory HouseTask({
    required String id,
    required TaskCategory category,
    required int severity,
    required Room room,
    required double x,
    required double y,
    required String createdBy,
    required DateTime createdAt,
    String? completedBy,
    DateTime? completedAt,
  }) = _HouseTask;
  const HouseTask._();

  factory HouseTask.fromJson(Map<String, dynamic> json) =>
      _$HouseTaskFromJson(json);

  /// Fantôme : marquée faite, en attente de validation par un autre membre.
  bool get awaitingValidation => completedBy != null;
}
