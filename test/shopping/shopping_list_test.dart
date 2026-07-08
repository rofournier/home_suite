import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/features/shopping/domain/shopping_category.dart';
import 'package:home_sweet_home/features/shopping/domain/shopping_item.dart';
import 'package:home_sweet_home/features/shopping/domain/shopping_list.dart';

ShoppingList listOf(List<String> categoryIds) => ShoppingList(
      householdId: 'h',
      categories: [
        for (final id in categoryIds) ShoppingCategory(id: id, name: id),
      ],
    );

void main() {
  group('gestion des onglets (logique pure)', () {
    test('addCategory ajoute en fin', () {
      final l = listOf(['a']).addCategory(
          const ShoppingCategory(id: 'b', name: 'B'));
      expect(l.categories.map((c) => c.id), ['a', 'b']);
    });

    test('renameCategory renomme', () {
      final l = listOf(['a']).renameCategory('a', 'Frais');
      expect(l.categories.single.name, 'Frais');
    });

    test('deleteCategory retire', () {
      final l = listOf(['a', 'b']).deleteCategory('a');
      expect(l.categories.map((c) => c.id), ['b']);
    });

    test('reorderCategories applique l\'ordre fourni', () {
      final l = listOf(['a', 'b', 'c']).reorderCategories(['c', 'a', 'b']);
      expect(l.categories.map((c) => c.id), ['c', 'a', 'b']);
    });

    test('reorderCategories préserve un onglet absent de l\'ordre reçu', () {
      final l = listOf(['a', 'b', 'c']).reorderCategories(['b', 'a']);
      expect(l.categories.map((c) => c.id), ['b', 'a', 'c']);
    });

    test('replaceCategory substitue la version transformée', () {
      final l = listOf(['a']).replaceCategory(
        ShoppingCategory(
          id: 'a',
          name: 'a',
          items: [
            ShoppingItem(
                id: 'x', text: 'Lait', createdBy: 'me', createdAt: DateTime(2026)),
          ],
        ),
      );
      expect(l.categoryById('a')!.items.single.text, 'Lait');
    });

    test('categoryById renvoie null si absent', () {
      expect(listOf(['a']).categoryById('z'), isNull);
    });
  });

  group('sérialisation JSON (futur DTO serveur)', () {
    test('round-trip conserve l\'état complet', () {
      final original = ShoppingList(
        householdId: 'h1',
        categories: [
          ShoppingCategory(
            id: 'c1',
            name: 'Frais',
            items: [
              ShoppingItem(
                id: 'i1',
                text: 'Tomates',
                bought: true,
                createdBy: 'marie',
                createdAt: DateTime(2026, 7, 8, 10, 30),
              ),
            ],
          ),
        ],
      );
      final restored = ShoppingList.fromJson(original.toJson());
      expect(restored, original);
    });
  });
}
