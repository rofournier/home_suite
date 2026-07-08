import 'package:freezed_annotation/freezed_annotation.dart';

import 'shopping_item.dart';

part 'shopping_category.freezed.dart';
part 'shopping_category.g.dart';

/// Un onglet de la liste (ex. « Frais »). Porte ses articles dans l'ordre
/// d'affichage. Les transformations d'édition sont **pures** (immuables, sans
/// génération d'id/date : ceux-ci sont injectés) → testables unitairement.
@freezed
abstract class ShoppingCategory with _$ShoppingCategory {
  const factory ShoppingCategory({
    required String id,
    required String name,
    @Default(<ShoppingItem>[]) List<ShoppingItem> items,
  }) = _ShoppingCategory;
  const ShoppingCategory._();

  factory ShoppingCategory.fromJson(Map<String, dynamic> json) =>
      _$ShoppingCategoryFromJson(json);

  int _indexOf(String itemId) => items.indexWhere((i) => i.id == itemId);

  /// Ajoute un article à la fin (ou à [at] si fourni).
  ShoppingCategory addItem(ShoppingItem item, {int? at}) {
    final next = [...items];
    next.insert((at ?? next.length).clamp(0, next.length), item);
    return copyWith(items: next);
  }

  ShoppingCategory updateText(String itemId, String text) {
    final i = _indexOf(itemId);
    if (i < 0) return this;
    final next = [...items];
    next[i] = next[i].copyWith(text: text);
    return copyWith(items: next);
  }

  ShoppingCategory toggleBought(String itemId) {
    final i = _indexOf(itemId);
    if (i < 0) return this;
    final next = [...items];
    next[i] = next[i].copyWith(bought: !next[i].bought);
    return copyWith(items: next);
  }

  ShoppingCategory deleteItem(String itemId) =>
      copyWith(items: items.where((i) => i.id != itemId).toList());

  /// Retire tous les articles achetés (« Nettoyer les achetés »).
  ShoppingCategory clearBought() =>
      copyWith(items: items.where((i) => !i.bought).toList());

  /// Retire les articles au texte vide (lignes ébauchées puis abandonnées).
  ShoppingCategory removeEmptyItems() =>
      copyWith(items: items.where((i) => i.text.trim().isNotEmpty).toList());

  bool get hasEmptyItems => items.any((i) => i.text.trim().isEmpty);

  /// Scinde l'article [itemId] à la position [cursor] du texte (touche Entrée).
  /// L'article courant garde l'avant-curseur ; [newItem] (id/auteur/date déjà
  /// fournis) reçoit l'après-curseur et est inséré juste en dessous.
  ShoppingCategory splitItem({
    required String itemId,
    required int cursor,
    required ShoppingItem newItem,
  }) {
    final i = _indexOf(itemId);
    if (i < 0) return this;
    final text = items[i].text;
    final at = cursor.clamp(0, text.length);
    final next = [...items];
    next[i] = next[i].copyWith(text: text.substring(0, at));
    next.insert(i + 1, newItem.copyWith(text: text.substring(at)));
    return copyWith(items: next);
  }

  /// Fusionne l'article [itemId] dans le précédent (Backspace en début de
  /// ligne) : le texte est ajouté au précédent, la row est supprimée. Renvoie
  /// aussi l'id de l'article à focus et la position du curseur (jonction).
  /// Sur le premier article : no-op.
  ({ShoppingCategory category, String focusItemId, int cursor}) mergeWithPrevious(
      String itemId) {
    final i = _indexOf(itemId);
    if (i <= 0) return (category: this, focusItemId: itemId, cursor: 0);
    final prev = items[i - 1];
    final junction = prev.text.length;
    final next = [...items];
    next[i - 1] = prev.copyWith(text: prev.text + items[i].text);
    next.removeAt(i);
    return (
      category: copyWith(items: next),
      focusItemId: prev.id,
      cursor: junction,
    );
  }

  int get boughtCount => items.where((i) => i.bought).length;
}
