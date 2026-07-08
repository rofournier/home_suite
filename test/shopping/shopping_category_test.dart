import 'package:flutter_test/flutter_test.dart';
import 'package:home_sweet_home/features/shopping/domain/shopping_category.dart';
import 'package:home_sweet_home/features/shopping/domain/shopping_item.dart';

ShoppingItem item(String id, String text, {bool bought = false}) => ShoppingItem(
      id: id,
      text: text,
      bought: bought,
      createdBy: 'me',
      createdAt: DateTime(2026),
    );

ShoppingCategory categoryOf(List<ShoppingItem> items) =>
    ShoppingCategory(id: 'c', name: 'Frais', items: items);

void main() {
  group('édition d\'articles (logique pure)', () {
    test('addItem ajoute en fin, ou à un index', () {
      final base = categoryOf([item('a', 'Tomates')]);
      expect(base.addItem(item('b', 'Lait')).items.map((i) => i.id),
          ['a', 'b']);
      expect(base.addItem(item('b', 'Lait'), at: 0).items.map((i) => i.id),
          ['b', 'a']);
    });

    test('toggleBought bascule l\'état', () {
      final c = categoryOf([item('a', 'Lait')]).toggleBought('a');
      expect(c.items.single.bought, isTrue);
      expect(c.toggleBought('a').items.single.bought, isFalse);
    });

    test('updateText remplace le texte', () {
      final c = categoryOf([item('a', 'Lait')]).updateText('a', 'Lait demi');
      expect(c.items.single.text, 'Lait demi');
    });

    test('deleteItem retire la row', () {
      final c = categoryOf([item('a', 'x'), item('b', 'y')]).deleteItem('a');
      expect(c.items.map((i) => i.id), ['b']);
    });

    test('clearBought ne garde que les non-achetés', () {
      final c = categoryOf([
        item('a', 'x', bought: true),
        item('b', 'y'),
        item('c', 'z', bought: true),
      ]).clearBought();
      expect(c.items.map((i) => i.id), ['b']);
      expect(c.boughtCount, 0);
    });

    test('splitItem scinde au curseur et insère la suite en dessous', () {
      final c = categoryOf([item('a', 'Pommes')]).splitItem(
        itemId: 'a',
        cursor: 3,
        newItem: item('b', ''),
      );
      expect(c.items.map((i) => i.id), ['a', 'b']);
      expect(c.items[0].text, 'Pom');
      expect(c.items[1].text, 'mes');
    });

    test('splitItem borne le curseur au texte', () {
      final c = categoryOf([item('a', 'Ok')]).splitItem(
        itemId: 'a',
        cursor: 99,
        newItem: item('b', ''),
      );
      expect(c.items[0].text, 'Ok');
      expect(c.items[1].text, '');
    });

    test('mergeWithPrevious fusionne dans le précédent et focus la jonction', () {
      final res =
          categoryOf([item('a', 'Tom'), item('b', 'ates')]).mergeWithPrevious('b');
      expect(res.category.items.map((i) => i.id), ['a']);
      expect(res.category.items.single.text, 'Tomates');
      expect(res.focusItemId, 'a');
      expect(res.cursor, 3);
    });

    test('mergeWithPrevious sur le premier article = no-op', () {
      final res = categoryOf([item('a', 'x')]).mergeWithPrevious('a');
      expect(res.category.items.map((i) => i.id), ['a']);
      expect(res.focusItemId, 'a');
      expect(res.cursor, 0);
    });
  });
}
