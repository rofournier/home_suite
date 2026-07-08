import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../../../household/domain/room.dart';
import '../../domain/task_category.dart';
import '../task_providers.dart';
import 'task_pin.dart';

/// Feuille d'ajout d'une tâche à la position normalisée ([x], [y]) tapée sur
/// le plan. Style « papier lofi » forcé (lisible sur tout thème système) :
/// grille d'emojis, sévérité en pastilles colorées, CTA terracotta.
/// Fermer sans valider = aucun pin créé.
Future<void> showAddTaskSheet(
  BuildContext context,
  WidgetRef ref, {
  required double x,
  required double y,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.paper,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: _AddTaskForm(
        onSubmit: (category, severity, room) {
          Navigator.of(sheetContext).pop();
          ref.read(taskRepositoryProvider).addTask(
              category: category, severity: severity, room: room, x: x, y: y);
        },
      ),
    ),
  );
}

class _AddTaskForm extends StatefulWidget {
  const _AddTaskForm({required this.onSubmit});

  final void Function(TaskCategory category, int severity, Room room) onSubmit;

  @override
  State<_AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<_AddTaskForm> {
  TaskCategory? _category;
  int _severity = 2;
  Room? _room;

  bool get _valid => _category != null && _room != null;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EmojiGrid(
            selected: _category,
            onSelect: (c) => setState(() => _category = c),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(flex: 3, child: _severityPills()),
              const SizedBox(width: AppSpacing.md),
              Expanded(flex: 2, child: _roomDropdown()),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.terracotta,
                foregroundColor: AppColors.onDopamine,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: _valid
                  ? () => widget.onSubmit(_category!, _severity, _room!)
                  : null,
              child: Text(_category == null
                  ? 'Choisis une tâche'
                  : 'Épingler ${_category!.emoji} ${_category!.label}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _severityPills() => Row(
        children: [
          for (var s = 1; s <= 3; s++) ...[
            if (s > 1) const SizedBox(width: AppSpacing.xs),
            Expanded(child: _SeverityPill(
              severity: s,
              selected: _severity == s,
              onTap: () => setState(() => _severity = s),
            )),
          ],
        ],
      );

  Widget _roomDropdown() => DropdownButtonFormField<Room>(
        initialValue: _room,
        dropdownColor: AppColors.paper,
        style: const TextStyle(color: AppColors.ink, fontSize: 15),
        iconEnabledColor: AppColors.inkSoft,
        decoration: InputDecoration(
          labelText: 'Pièce',
          labelStyle: const TextStyle(color: AppColors.inkSoft),
          isDense: true,
          filled: true,
          fillColor: AppColors.cream,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
            borderSide: const BorderSide(color: AppColors.sand),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
            borderSide: const BorderSide(color: AppColors.sand),
          ),
        ),
        items: [
          for (final room in Room.values)
            DropdownMenuItem(value: room, child: Text(room.label)),
        ],
        onChanged: (room) => setState(() => _room = room),
      );
}

/// Grille des catégories : tuiles emoji rondes, anneau terracotta quand
/// sélectionnée, libellé sous la tuile. Cibles ≥48dp.
class _EmojiGrid extends StatelessWidget {
  const _EmojiGrid({required this.selected, required this.onSelect});

  final TaskCategory? selected;
  final ValueChanged<TaskCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        for (final category in TaskCategory.values)
          _EmojiTile(
            category: category,
            selected: category == selected,
            onTap: () => onSelect(category),
          ),
      ],
    );
  }
}

class _EmojiTile extends StatelessWidget {
  const _EmojiTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final TaskCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Semantics(
      button: true,
      selected: selected,
      label: category.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: reduceMotion ? 0 : 160),
                curve: Curves.easeOut,
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.insertHighlight : AppColors.cream,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.terracotta : AppColors.sand,
                    width: selected ? 3 : 1.5,
                  ),
                ),
                child: Text(category.emoji,
                    style: const TextStyle(fontSize: 22, height: 1)),
              ),
              const SizedBox(height: 2),
              Text(
                category.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: selected ? AppColors.ink : AppColors.inkSoft,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pastille de sévérité : couleur pleine quand choisie, contour sinon.
class _SeverityPill extends StatelessWidget {
  const _SeverityPill({
    required this.severity,
    required this.selected,
    required this.onTap,
  });

  final int severity;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = severityColor(severity);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : AppColors.cream,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: selected ? color : AppColors.sand,
              width: 1.5),
        ),
        child: Text(
          severityLabel(severity),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? AppColors.onDopamine : AppColors.inkSoft,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
