import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../../domain/document_sort.dart';
import '../document_providers.dart';

/// Barre de tri : choix du critère (Date / Titre) + inversion du sens. Change
/// [documentSortProvider] → la grille se réordonne avec animation.
class DocumentSortControl extends ConsumerWidget {
  const DocumentSortControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(documentSortProvider);
    final notifier = ref.read(documentSortProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text('Trier', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: AppSpacing.sm),
          _FieldChip(
            label: 'Date',
            selected: sort.field == DocSortField.date,
            onTap: () => notifier.setField(DocSortField.date),
          ),
          const SizedBox(width: AppSpacing.xs),
          _FieldChip(
            label: 'Titre',
            selected: sort.field == DocSortField.title,
            onTap: () => notifier.setField(DocSortField.title),
          ),
          const Spacer(),
          IconButton(
            onPressed: notifier.toggleOrder,
            tooltip: sort.ascending ? 'Croissant' : 'Décroissant',
            icon: Icon(sort.ascending
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded),
            color: AppColors.terracotta,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ],
      ),
    );
  }
}

class _FieldChip extends StatelessWidget {
  const _FieldChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? AppColors.terracotta : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: selected ? AppColors.terracotta : AppColors.sand,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.onDopamine : AppColors.inkSoft,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
