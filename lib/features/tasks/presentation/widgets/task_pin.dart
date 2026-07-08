import 'package:flutter/material.dart';

import '../../../../app/theme_tokens.dart';
import '../../domain/house_task.dart';

/// Couleur de sévérité : 1 = peut attendre, 2 = à faire, 3 = urgent.
Color severityColor(int severity) => switch (severity) {
      1 => AppColors.sage,
      2 => AppColors.amber,
      _ => AppColors.terracotta,
    };

String severityLabel(int severity) => switch (severity) {
      1 => 'Tranquille',
      2 => 'À faire',
      _ => 'Urgent',
    };

/// Pin d'une tâche sur le plan : pastille papier + anneau de sévérité +
/// icône de catégorie. Hit-target 48dp quel que soit le visuel.
class TaskPin extends StatelessWidget {
  const TaskPin({super.key, required this.task, required this.onTap});

  final HouseTask task;
  final VoidCallback onTap;

  /// Diamètre visuel selon la sévérité (le hit reste 48).
  double get _visual => 30.0 + task.severity * 4;

  @override
  Widget build(BuildContext context) {
    final ghost = task.awaitingValidation;
    final color = ghost ? AppColors.sage : severityColor(task.severity);
    return Semantics(
      button: true,
      label: '${task.category.label}, ${severityLabel(task.severity)}, '
          '${task.room.label}'
          '${ghost ? ', en attente de validation' : ''}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            // Fantôme : pin translucide + coche sage en attendant que le
            // créateur valide la complétion.
            child: Opacity(
              opacity: ghost ? 0.55 : 1,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: _visual,
                    height: _visual,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      task.category.emoji,
                      style: TextStyle(fontSize: _visual * 0.48, height: 1),
                    ),
                  ),
                  if (ghost)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.sage,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 13, color: AppColors.onDopamine),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
