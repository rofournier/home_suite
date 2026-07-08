import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../../domain/shopping_category.dart';
import '../shopping_notif.dart';
import '../shopping_providers.dart';
import 'category_dialogs.dart';

/// Barre d'onglets : sélection, badge « nouveau », drag-reorder (long-press),
/// et gestion (renommer/supprimer) au re-tap de l'onglet actif.
class CategoryTabs extends ConsumerWidget {
  const CategoryTabs({
    super.key,
    required this.categories,
    required this.activeId,
  });

  final List<ShoppingCategory> categories;
  final String activeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unseen = ref.watch(
        shoppingNotifProvider.select((s) => s.unseenByCategory));
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              buildDefaultDragHandles: true,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              itemCount: categories.length,
              onReorderItem: (oldIndex, newIndex) =>
                  _reorder(ref, oldIndex, newIndex),
              itemBuilder: (context, index) {
                final category = categories[index];
                return _TabChip(
                  key: ValueKey(category.id),
                  label: category.name,
                  active: category.id == activeId,
                  unseen: unseen[category.id] ?? 0,
                  onTap: () => _onTap(context, ref, category),
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
    final ids = categories.map((c) => c.id).toList();
    final id = ids.removeAt(oldIndex);
    ids.insert(newIndex, id);
    ref.read(shoppingRepositoryProvider).reorderCategories(ids);
  }

  Future<void> _onTap(
      BuildContext context, WidgetRef ref, ShoppingCategory category) async {
    if (category.id != activeId) {
      ref.read(activeCategoryProvider.notifier).select(category.id);
      ref.read(shoppingNotifProvider.notifier).markCategorySeen(category.id);
      return;
    }
    await manageCategory(context, ref, category, canDelete: categories.length > 1);
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final name = await promptCategoryName(context);
    if (name == null || name.isEmpty) return;
    final id = await ref.read(shoppingRepositoryProvider).addCategory(name);
    ref.read(activeCategoryProvider.notifier).select(id);
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    super.key,
    required this.label,
    required this.active,
    required this.unseen,
    required this.onTap,
  });

  final String label;
  final bool active;
  final int unseen;
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (unseen > 0) ...[
                const SizedBox(width: AppSpacing.xs),
                const _NewDot(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NewDot extends StatelessWidget {
  const _NewDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.dopamine,
        shape: BoxShape.circle,
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
