import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../../domain/document_tab.dart';
import '../document_providers.dart';
import 'document_tab_dialogs.dart';

/// Barre d'onglets Documents : sélection, drag-reorder (long-press), et gestion
/// (renommer/supprimer) au re-tap de l'onglet actif. Miroir des onglets Courses.
class DocumentTabs extends ConsumerWidget {
  const DocumentTabs({super.key, required this.tabs, required this.activeId});

  final List<DocumentTab> tabs;
  final String activeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              itemCount: tabs.length,
              onReorderItem: (oldIndex, newIndex) =>
                  _reorder(ref, oldIndex, newIndex),
              itemBuilder: (context, index) {
                final tab = tabs[index];
                return _TabChip(
                  key: ValueKey(tab.id),
                  label: tab.name,
                  active: tab.id == activeId,
                  onTap: () => _onTap(context, ref, tab),
                );
              },
            ),
          ),
          _AddButton(onTap: () => _add(context, ref)),
        ],
      ),
    );
  }

  void _reorder(WidgetRef ref, int oldIndex, int newIndex) {
    final ids = tabs.map((t) => t.id).toList();
    final id = ids.removeAt(oldIndex);
    ids.insert(newIndex, id);
    ref.read(documentRepositoryProvider).reorderTabs(ids);
  }

  Future<void> _onTap(
      BuildContext context, WidgetRef ref, DocumentTab tab) async {
    if (tab.id != activeId) {
      ref.read(activeDocTabProvider.notifier).select(tab.id);
      return;
    }
    await manageTab(context, ref, tab, canDelete: tabs.length > 1);
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final name = await promptTabName(context);
    if (name == null || name.isEmpty) return;
    final id = await ref.read(documentRepositoryProvider).addTab(name);
    ref.read(activeDocTabProvider.notifier).select(id);
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active ? AppColors.terracotta : AppColors.inkSoft;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.terracotta : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(Icons.add_rounded),
      color: AppColors.terracotta,
      tooltip: 'Nouvel onglet',
      iconSize: 24,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );
  }
}
