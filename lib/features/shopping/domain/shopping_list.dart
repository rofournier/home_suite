import 'package:freezed_annotation/freezed_annotation.dart';

import 'shopping_category.dart';

part 'shopping_list.freezed.dart';
part 'shopping_list.g.dart';

/// Agrégat persisté d'une maison : ses onglets de courses, dans l'ordre.
/// Source de vérité locale (offline-first). Sérialisable = futur DTO serveur.
/// Les mutations de catégories sont pures (immuables) → testables.
@freezed
abstract class ShoppingList with _$ShoppingList {
  const factory ShoppingList({
    required String householdId,
    @Default(<ShoppingCategory>[]) List<ShoppingCategory> categories,
    // Horodatage de dernière mutation locale (LWW) : un état entrant plus
    // vieux que le nôtre est ignoré (protège les modifs faites hors ligne).
    DateTime? updatedAt,
  }) = _ShoppingList;
  const ShoppingList._();

  factory ShoppingList.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListFromJson(json);

  int _indexOf(String categoryId) =>
      categories.indexWhere((c) => c.id == categoryId);

  ShoppingCategory? categoryById(String categoryId) {
    final i = _indexOf(categoryId);
    return i < 0 ? null : categories[i];
  }

  ShoppingList addCategory(ShoppingCategory category) =>
      copyWith(categories: [...categories, category]);

  ShoppingList renameCategory(String categoryId, String name) {
    final i = _indexOf(categoryId);
    if (i < 0) return this;
    final next = [...categories];
    next[i] = next[i].copyWith(name: name);
    return copyWith(categories: next);
  }

  ShoppingList deleteCategory(String categoryId) =>
      copyWith(categories: categories.where((c) => c.id != categoryId).toList());

  /// Réordonne les onglets selon la liste d'ids fournie (drag-reorder).
  ShoppingList reorderCategories(List<String> orderedIds) {
    final byId = {for (final c in categories) c.id: c};
    final reordered = [
      for (final id in orderedIds)
        if (byId[id] != null) byId[id]!,
    ];
    // Garde-fou : conserve d'éventuelles catégories absentes de l'ordre reçu.
    final missing = categories.where((c) => !orderedIds.contains(c.id));
    return copyWith(categories: [...reordered, ...missing]);
  }

  /// Remplace une catégorie par sa version transformée (après édition d'items).
  ShoppingList replaceCategory(ShoppingCategory category) {
    final i = _indexOf(category.id);
    if (i < 0) return this;
    final next = [...categories];
    next[i] = category;
    return copyWith(categories: next);
  }
}
