import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../../domain/shopping_category.dart';
import '../../domain/shopping_item.dart';
import '../../domain/shopping_repository.dart';
import '../shopping_providers.dart';
import 'notepad_background.dart';
import 'shopping_row.dart';

/// Corps « bloc-note » d'un onglet : réglure + rows éditables. Détient les
/// contrôleurs/focus des champs (clé = id d'article) et orchestre l'édition
/// (frappe, Entrée=split, Backspace-début=fusion, focus, surbrillance, Undo).
class NotepadList extends ConsumerStatefulWidget {
  const NotepadList({super.key, required this.category});

  final ShoppingCategory category;

  @override
  ConsumerState<NotepadList> createState() => _NotepadListState();
}

class _NotepadListState extends ConsumerState<NotepadList> {
  final _controllers = <String, TextEditingController>{};
  final _focusNodes = <String, FocusNode>{};
  final _recentTimers = <String, Timer>{};
  final _recentlyAdded = <String>{};
  ({String id, int offset})? _pendingFocus;

  // Ligne d'écriture en bas du bloc-note. Non persistée tant qu'on ne valide
  // pas → aucun article vide créé « pour rien ».
  final _ghostController = TextEditingController();
  late final FocusNode _ghostFocus = FocusNode()..addListener(_onGhostFocus);

  // Repo capturé tôt : réutilisable dans dispose() sans passer par `ref`
  // (interdit une fois le widget démonté).
  late final ShoppingRepository _repo;

  String get _categoryId => widget.category.id;

  @override
  void initState() {
    super.initState();
    _repo = ref.read(shoppingRepositoryProvider);
  }

  @override
  void dispose() {
    // En quittant l'onglet/l'écran : valide une ébauche non vide, puis purge
    // les lignes vides restantes (y compris celles laissées par split/merge).
    _ghostFocus.removeListener(_onGhostFocus);
    _flushOnLeave();
    _ghostController.dispose();
    _ghostFocus.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _focusNodes.values) {
      f.dispose();
    }
    for (final t in _recentTimers.values) {
      t.cancel();
    }
    super.dispose();
  }

  void _onGhostFocus() {
    if (!_ghostFocus.hasFocus) _commitGhost();
  }

  /// Valide la ligne d'écriture : crée l'article si le texte n'est pas vide,
  /// puis vide le champ pour enchaîner. No-op si vide.
  void _commitGhost() {
    final text = _ghostController.text.trim();
    if (text.isEmpty) return;
    _ghostController.clear();
    _repo.addItem(_categoryId, text: text);
  }

  void _onGhostSubmitted(String _) {
    _commitGhost();
    // Garder le clavier ouvert pour saisir l'article suivant.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ghostFocus.requestFocus();
    });
  }

  void _flushOnLeave() {
    _commitGhost();
    _repo.clearEmpty(_categoryId);
  }

  TextEditingController _controllerFor(ShoppingItem item, bool hasFocus) {
    final controller =
        _controllers.putIfAbsent(item.id, () => TextEditingController(text: item.text));
    // Ne pas écraser la saisie en cours ; sync seulement sur maj externe.
    if (!hasFocus && controller.text != item.text) {
      controller.text = item.text;
    }
    return controller;
  }

  FocusNode _focusFor(String itemId) {
    return _focusNodes.putIfAbsent(
      itemId,
      () => FocusNode(
        onKeyEvent: (node, event) => _onKey(itemId, event),
      ),
    );
  }

  KeyEventResult _onKey(String itemId, KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }
    final controller = _controllers[itemId];
    if (controller == null) return KeyEventResult.ignored;
    final sel = controller.selection;
    final atStart = controller.text.isEmpty ||
        (sel.isCollapsed && sel.baseOffset == 0);
    if (!atStart) return KeyEventResult.ignored;
    _merge(itemId);
    return KeyEventResult.handled;
  }

  void _markRecentlyAdded(String id) {
    _recentTimers[id]?.cancel();
    _recentlyAdded.add(id);
    _recentTimers[id] = Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _recentlyAdded.remove(id));
    });
  }

  Future<void> _onChanged(String itemId, String text) =>
      ref.read(shoppingRepositoryProvider).updateItemText(_categoryId, itemId, text);

  Future<void> _onEnter(String itemId, String before, String after) async {
    final repo = ref.read(shoppingRepositoryProvider);
    await repo.updateItemText(_categoryId, itemId, before + after);
    final created = await repo.splitItem(_categoryId, itemId, before.length);
    _focusAfterBuild(created.id, 0);
    _markRecentlyAdded(created.id);
  }

  Future<void> _merge(String itemId) async {
    final res = await ref.read(shoppingRepositoryProvider).mergeItem(_categoryId, itemId);
    _focusAfterBuild(res.focusItemId, res.cursor);
  }

  void _delete(ShoppingItem item, int index) {
    ref.read(shoppingRepositoryProvider).deleteItem(_categoryId, item.id);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Article supprimé'),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () => ref
              .read(shoppingRepositoryProvider)
              .restoreItem(_categoryId, item, index),
        ),
      ),
    );
  }

  void _focusAfterBuild(String itemId, int offset) {
    _pendingFocus = (id: itemId, offset: offset);
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyPendingFocus());
  }

  void _applyPendingFocus() {
    final pending = _pendingFocus;
    if (pending == null || !mounted) return;
    final controller = _controllers[pending.id];
    final node = _focusNodes[pending.id];
    if (controller == null || node == null) return;
    _pendingFocus = null;
    final offset = pending.offset.clamp(0, controller.text.length);
    controller.selection = TextSelection.collapsed(offset: offset);
    node.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    // Source fraîche : la catégorie courante du flux (items à jour).
    final category = ref
            .watch(shoppingListProvider)
            .whenOrNull(data: (list) => list.categoryById(_categoryId)) ??
        widget.category;
    final items = category.items;

    return NotepadBackground(
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(
            left: AppSpacing.md, bottom: AppSpacing.xxl, top: AppSpacing.xs),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == items.length) {
            return _GhostRow(
              controller: _ghostController,
              focusNode: _ghostFocus,
              onSubmitted: _onGhostSubmitted,
            );
          }
          final item = items[index];
          final node = _focusFor(item.id);
          final controller = _controllerFor(item, node.hasFocus);
          return ShoppingRow(
            key: ValueKey(item.id),
            item: item,
            controller: controller,
            focusNode: node,
            highlighted: _recentlyAdded.contains(item.id),
            onChanged: (text) => _onChanged(item.id, text),
            onEnter: (before, after) => _onEnter(item.id, before, after),
            onToggle: () =>
                ref.read(shoppingRepositoryProvider).toggleBought(_categoryId, item.id),
            onDelete: () => _delete(item, index),
          );
        },
      ),
    );
  }
}

/// Ligne d'écriture en bas du bloc-note : un champ manuscrit prêt à saisir,
/// sans bouton. Rien n'est créé tant qu'on ne valide pas (Entrée) ou qu'on ne
/// quitte pas le champ avec du texte → pas d'article vide.
class _GhostRow extends StatelessWidget {
  const _GhostRow({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kRowHeight),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Espace d'alignement : cale le texte sur les lignes du dessus
          // (pas de puce cliquable ici, c'est juste la ligne d'écriture).
          const SizedBox(width: kRowHeight, height: kRowHeight),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: 1,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              style: itemTextStyle(context, bought: false),
              cursorColor: AppColors.terracotta,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10)
              ),
              onSubmitted: onSubmitted,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}
