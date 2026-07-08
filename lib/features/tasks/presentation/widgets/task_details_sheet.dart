import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../../../household/presentation/household_providers.dart';
import '../../domain/house_task.dart';
import '../task_providers.dart';
import 'task_pin.dart';

/// Détails d'une tâche épinglée. Anti-triche :
/// - Tâche active : « C'est fait » → fantôme (jamais de disparition directe).
/// - Fantôme : tout membre **autre que le complétant** voit Valider/Refuser ;
///   le complétant peut seulement annuler sa complétion.
Future<void> showTaskDetailsSheet(
  BuildContext context,
  WidgetRef ref,
  HouseTask task,
) {
  final household = ref.read(householdProvider);
  final meId = ref.read(currentMemberProvider).id;
  String nameOf(String? id) =>
      household.members
          .where((m) => m.id == id)
          .map((m) => m.displayName)
          .firstOrNull ??
      'Quelqu\'un';

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.paper,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(task: task, author: nameOf(task.createdBy)),
            const SizedBox(height: AppSpacing.md),
            if (!task.awaitingValidation)
              _completeButton(context, sheetContext, ref, task)
            else if (task.completedBy != meId)
              _validationRow(context, sheetContext, ref, task,
                  completerName: nameOf(task.completedBy))
            else
              _ownCompletion(context, sheetContext, ref, task),
          ],
        ),
      ),
    ),
  );
}

Widget _completeButton(BuildContext context, BuildContext sheetContext,
    WidgetRef ref, HouseTask task) {
  return SizedBox(
    height: 52,
    child: FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.sage,
        foregroundColor: AppColors.onDopamine,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      onPressed: () {
        Navigator.of(sheetContext).pop();
        _complete(context, ref, task);
      },
      icon: const Icon(Icons.check_rounded),
      label: const Text('C\'est fait'),
    ),
  );
}

Widget _validationRow(BuildContext context, BuildContext sheetContext,
    WidgetRef ref, HouseTask task,
    {required String completerName}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Fait par $completerName — à toi de juger !',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.inkSoft),
      ),
      const SizedBox(height: AppSpacing.sm),
      Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.sage,
                  foregroundColor: AppColors.onDopamine,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  ref.read(taskRepositoryProvider).validateTask(task.id);
                },
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Valider'),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.terracotta,
                  side: const BorderSide(
                      color: AppColors.terracotta, width: 1.5),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  ref.read(taskRepositoryProvider).rejectTask(task.id);
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Refuser'),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

/// Le complétant revoit sa propre complétion : il attend, ou l'annule.
Widget _ownCompletion(BuildContext context, BuildContext sheetContext,
    WidgetRef ref, HouseTask task) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
        child: const Text(
          '✅ Fait par toi — un autre membre doit valider pour que la tâche '
          'disparaisse (et que tu marques tes points).',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.inkSoft),
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(sheetContext).pop();
          ref.read(taskRepositoryProvider).reopenTask(task.id);
        },
        child: const Text('Annuler ma complétion'),
      ),
    ],
  );
}

void _complete(BuildContext context, WidgetRef ref, HouseTask task) {
  ref.read(taskRepositoryProvider).completeTask(task.id);
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
          '${task.category.label} fait — en attente de validation d\'un autre membre'),
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'Annuler',
        onPressed: () => ref.read(taskRepositoryProvider).reopenTask(task.id),
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.task, required this.author});

  final HouseTask task;
  final String author;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = severityColor(task.severity);
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.cream,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Text(task.category.emoji,
              style: const TextStyle(fontSize: 22, height: 1)),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Couleurs forcées : la feuille est papier quel que soit le
              // thème système (contraste garanti).
              Text(task.category.label,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: AppColors.ink)),
              Text(
                '${task.room.label} · ${severityLabel(task.severity)}'
                ' · par $author',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.inkSoft),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
