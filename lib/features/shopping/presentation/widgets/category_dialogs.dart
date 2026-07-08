import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../../domain/shopping_category.dart';
import '../shopping_providers.dart';

/// Demande un nom d'onglet (création). Renvoie `null` si annulé.
Future<String?> promptCategoryName(BuildContext context, {String initial = ''}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _NameDialog(
      title: initial.isEmpty ? 'Nouvel onglet' : 'Renommer l\'onglet',
      initial: initial,
    ),
  );
}

/// Feuille de gestion de l'onglet actif : renommer / supprimer.
Future<void> manageCategory(
  BuildContext context,
  WidgetRef ref,
  ShoppingCategory category, {
  required bool canDelete,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Renommer'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final name =
                  await promptCategoryName(context, initial: category.name);
              if (name != null && name.isNotEmpty) {
                await ref
                    .read(shoppingRepositoryProvider)
                    .renameCategory(category.id, name);
              }
            },
          ),
          ListTile(
            enabled: canDelete,
            leading: Icon(Icons.delete_outline_rounded,
                color: canDelete ? AppColors.terracotta : null),
            title: Text('Supprimer',
                style: TextStyle(
                    color: canDelete ? AppColors.terracotta : null)),
            subtitle: canDelete
                ? null
                : const Text('Impossible : dernier onglet'),
            onTap: canDelete
                ? () async {
                    Navigator.of(sheetContext).pop();
                    final ok = await _confirmDelete(context, category.name);
                    if (ok) {
                      await ref
                          .read(shoppingRepositoryProvider)
                          .deleteCategory(category.id);
                    }
                  }
                : null,
          ),
        ],
      ),
    ),
  );
}

Future<bool> _confirmDelete(BuildContext context, String name) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Supprimer « $name » ?'),
      content: const Text('Les articles de cet onglet seront perdus.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.terracotta),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
  return ok ?? false;
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, required this.initial});

  final String title;
  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Nom',
          hintText: 'Ex. Frais, Maison, Pharmacie',
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(onPressed: _submit, child: const Text('OK')),
      ],
    );
  }
}
