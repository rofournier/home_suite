import 'package:freezed_annotation/freezed_annotation.dart';

import 'house_task.dart';

part 'task_board.freezed.dart';
part 'task_board.g.dart';

/// Score cumulé d'un membre au leaderboard (survit à la disparition des
/// tâches). `points` = somme des sévérités des tâches terminées.
@freezed
abstract class MemberScore with _$MemberScore {
  const factory MemberScore({
    required String memberId,
    @Default(0) int points,
    @Default(0) int completedCount,
    @Default(0) int createdCount,
  }) = _MemberScore;

  factory MemberScore.fromJson(Map<String, dynamic> json) =>
      _$MemberScoreFromJson(json);
}

/// Agrégat persisté d'une maison : ses tâches épinglées sur le plan + les
/// scores du leaderboard. Source de vérité locale (offline-first),
/// synchronisé en état complet (LWW via `updatedAt`).
@freezed
abstract class TaskBoard with _$TaskBoard {
  const factory TaskBoard({
    required String householdId,
    @Default(<HouseTask>[]) List<HouseTask> tasks,
    @Default(<MemberScore>[]) List<MemberScore> scores,
    DateTime? updatedAt,
  }) = _TaskBoard;
  const TaskBoard._();

  factory TaskBoard.fromJson(Map<String, dynamic> json) =>
      _$TaskBoardFromJson(json);

  HouseTask? taskById(String id) {
    final i = tasks.indexWhere((t) => t.id == id);
    return i < 0 ? null : tasks[i];
  }

  TaskBoard addTask(HouseTask task) => copyWith(tasks: [...tasks, task]);

  TaskBoard removeTask(String id) =>
      copyWith(tasks: tasks.where((t) => t.id != id).toList());

  TaskBoard replaceTask(HouseTask task) {
    final i = tasks.indexWhere((t) => t.id == task.id);
    if (i < 0) return this;
    final next = [...tasks];
    next[i] = task;
    return copyWith(tasks: next);
  }

  /// Marque une tâche « faite » sans la retirer (mode à valider → fantôme).
  TaskBoard markCompleted(String id, {required String by, required DateTime at}) {
    final task = taskById(id);
    if (task == null) return this;
    return replaceTask(task.copyWith(completedBy: by, completedAt: at));
  }

  /// Ré-active une tâche fantôme (refus de validation, ou Annuler).
  TaskBoard reopenTask(String id) {
    final task = taskById(id);
    if (task == null) return this;
    return replaceTask(task.copyWith(completedBy: null, completedAt: null));
  }

  MemberScore scoreOf(String memberId) => scores.firstWhere(
        (s) => s.memberId == memberId,
        orElse: () => MemberScore(memberId: memberId),
      );

  TaskBoard _upsertScore(MemberScore score) => copyWith(scores: [
        for (final s in scores)
          if (s.memberId != score.memberId) s,
        score,
      ]);

  /// Crédite le complétant : points (sévérité) + compteur de tâches faites.
  /// [count]/[points] négatifs = décrédit (Annuler une complétion).
  TaskBoard creditCompletion(String memberId, int points, {int count = 1}) {
    final s = scoreOf(memberId);
    return _upsertScore(s.copyWith(
      points: (s.points + points).clamp(0, 1 << 30),
      completedCount: (s.completedCount + count).clamp(0, 1 << 30),
    ));
  }

  /// Compte une tâche proposée par [memberId].
  TaskBoard creditCreation(String memberId) {
    final s = scoreOf(memberId);
    return _upsertScore(s.copyWith(createdCount: s.createdCount + 1));
  }
}
