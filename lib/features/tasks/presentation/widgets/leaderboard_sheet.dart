import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../../../household/presentation/household_providers.dart';
import '../../domain/scoring.dart';
import '../../domain/task_board.dart';
import '../task_providers.dart';

/// 🏆 Leaderboard du foyer : classement par points (sévérité des tâches
/// terminées), avec titre par palier et compteurs faites/proposées.
Future<void> showLeaderboardSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    // En paysage la hauteur par défaut ne montre qu'une ligne : on autorise
    // la sheet à monter à 85 % de l'écran, la liste scrolle en dessous.
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.85,
    ),
    backgroundColor: AppColors.paper,
    builder: (sheetContext) => const SafeArea(child: _Leaderboard()),
  );
}

class _Leaderboard extends ConsumerWidget {
  const _Leaderboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(taskBoardProvider).asData?.value;
    final household = ref.watch(householdProvider);
    final rows = [
      for (final member in household.members)
        (
          name: member.displayName,
          score: board?.scoreOf(member.id) ?? MemberScore(memberId: member.id),
        ),
    ]..sort((a, b) => b.score.points.compareTo(a.score.points));

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('🏆 Leaderboard',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: AppColors.ink)),
          const SizedBox(height: AppSpacing.md),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: rows.length,
              itemBuilder: (_, i) =>
                  _Row(rank: i, name: rows[i].name, score: rows[i].score),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.rank, required this.name, required this.score});

  final int rank;
  final String name;
  final MemberScore score;

  static const _medals = ['🥇', '🥈', '🥉'];

  @override
  Widget build(BuildContext context) {
    final first = rank == 0 && score.points > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: first ? AppColors.insertHighlight : AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(
            color: first ? AppColors.amber : AppColors.sand, width: 1.5),
      ),
      child: Row(
        children: [
          Text(
            rank < _medals.length ? _medals[rank] : ' ${rank + 1} ',
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                Text(
                  '${titleForPoints(score.points)} · '
                  '${score.completedCount} faite${score.completedCount > 1 ? 's' : ''} · '
                  '${score.createdCount} proposée${score.createdCount > 1 ? 's' : ''}',
                  style:
                      const TextStyle(color: AppColors.inkSoft, fontSize: 13),
                ),
              ],
            ),
          ),
          Text('${score.points} pts',
              style: const TextStyle(
                  color: AppColors.terracotta,
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
        ],
      ),
    );
  }
}
