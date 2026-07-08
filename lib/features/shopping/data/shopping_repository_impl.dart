import 'dart:async';

import '../../../core/realtime/realtime_service.dart';
import '../../household/domain/household.dart';
import '../domain/shopping_category.dart';
import '../domain/shopping_item.dart';
import '../domain/shopping_list.dart';
import '../domain/shopping_repository.dart';
import 'shopping_events.dart';
import 'shopping_local_datasource.dart';

/// Génère un id unique sans dépendance externe (timestamp + compteur).
class IdGenerator {
  int _counter = 0;
  String next() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-${_counter++}';
}

/// Impl locale de [ShoppingRepository]. Tient la liste en mémoire (miroir de
/// `shared_preferences`), applique les transformations **pures** du domaine,
/// persiste, émet sur le flux, et **publie chaque mutation** sur le
/// `RealtimeService` (plomberie server-ready).
class ShoppingRepositoryImpl implements ShoppingRepository {
  ShoppingRepositoryImpl({
    required this._datasource,
    required this._realtime,
    required this._household,
    required this._currentMember,
    IdGenerator? idGenerator,
    DateTime Function()? clock,
    this._seedCategories = const ['Frais', 'Maison', 'Pharmacie'],
  })  : _ids = idGenerator ?? IdGenerator(),
        _now = clock ?? DateTime.now;

  final ShoppingLocalDatasource _datasource;
  final RealtimeService _realtime;
  final Household _household;
  final Member _currentMember;
  final IdGenerator _ids;
  final DateTime Function() _now;
  final List<String> _seedCategories;

  final _controller = StreamController<ShoppingList>.broadcast();
  late ShoppingList _list;
  bool _initialized = false;

  @override
  Stream<ShoppingList> watch() async* {
    await _ready();
    yield _list;
    yield* _controller.stream;
  }

  /// Charge l'état persisté, ou seede les onglets par défaut **et les persiste**
  /// (pour qu'ils survivent au redémarrage même sans édition).
  Future<void> _ready() async {
    if (_initialized) return;
    final loaded = _datasource.load(_household.id);
    _initialized = true;
    if (loaded != null) {
      _list = loaded;
      return;
    }
    _list = _seed();
    await _datasource.save(_list);
  }

  ShoppingList _seed() => ShoppingList(
        householdId: _household.id,
        categories: [
          for (final name in _seedCategories)
            ShoppingCategory(id: _ids.next(), name: name),
        ],
      );

  ShoppingItem _newItem(String text) => ShoppingItem(
        id: _ids.next(),
        text: text,
        createdBy: _currentMember.id,
        createdAt: _now(),
      );

  Future<void> _commit(ShoppingList next) async {
    _list = next.copyWith(updatedAt: _now());
    await _datasource.save(_list);
    _controller.add(_list);
    // Sync temps réel : porte l'état complet (le serveur persiste + rediffuse).
    await _realtime.publish(shoppingSyncEvent(_list.toJson()));
  }

  @override
  Future<void> applyRemote(ShoppingList list) async {
    await _ready();
    // LWW : ignore un état plus vieux que le nôtre (ex. le serveur repousse
    // un état d'avant nos modifs hors ligne à la reconnexion).
    final local = _list.updatedAt;
    final incoming = list.updatedAt;
    if (local != null && (incoming == null || incoming.isBefore(local))) {
      return;
    }
    _list = list;
    await _datasource.save(list);
    _controller.add(list);
  }

  @override
  Future<void> republish() async {
    await _ready();
    await _realtime.publish(shoppingSyncEvent(_list.toJson()));
  }

  Future<void> _publishAdded(ShoppingCategory category, ShoppingItem item) =>
      _realtime.publish(itemAddedEvent(
        householdId: _household.id,
        categoryId: category.id,
        categoryName: category.name,
        authorName: _currentMember.displayName,
        item: item,
      ));

  ShoppingCategory _requireCategory(String categoryId) {
    final category = _list.categoryById(categoryId);
    if (category == null) {
      throw StateError('Catégorie introuvable : $categoryId');
    }
    return category;
  }

  @override
  Future<String> addCategory(String name) async {
    await _ready();
    final id = _ids.next();
    await _commit(_list.addCategory(ShoppingCategory(id: id, name: name)));
    return id;
  }

  @override
  Future<void> renameCategory(String categoryId, String name) async {
    await _ready();
    await _commit(_list.renameCategory(categoryId, name));
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _ready();
    await _commit(_list.deleteCategory(categoryId));
  }

  @override
  Future<void> reorderCategories(List<String> orderedIds) async {
    await _ready();
    await _commit(_list.reorderCategories(orderedIds));
  }

  @override
  Future<ShoppingItem> addItem(String categoryId, {String text = ''}) async {
    await _ready();
    final category = _requireCategory(categoryId);
    final item = _newItem(text);
    await _commit(_list.replaceCategory(category.addItem(item)));
    await _publishAdded(category, item);
    return item;
  }

  @override
  Future<void> updateItemText(
      String categoryId, String itemId, String text) async {
    await _ready();
    final category = _requireCategory(categoryId);
    await _commit(_list.replaceCategory(category.updateText(itemId, text)));
  }

  @override
  Future<void> toggleBought(String categoryId, String itemId) async {
    await _ready();
    final category = _requireCategory(categoryId);
    await _commit(_list.replaceCategory(category.toggleBought(itemId)));
  }

  @override
  Future<void> deleteItem(String categoryId, String itemId) async {
    await _ready();
    final category = _requireCategory(categoryId);
    await _commit(_list.replaceCategory(category.deleteItem(itemId)));
  }

  @override
  Future<void> restoreItem(
      String categoryId, ShoppingItem item, int index) async {
    await _ready();
    final category = _requireCategory(categoryId);
    await _commit(_list.replaceCategory(category.addItem(item, at: index)));
  }

  @override
  Future<ShoppingItem> splitItem(
      String categoryId, String itemId, int cursor) async {
    await _ready();
    final category = _requireCategory(categoryId);
    final newItem = _newItem('');
    final updated =
        category.splitItem(itemId: itemId, cursor: cursor, newItem: newItem);
    await _commit(_list.replaceCategory(updated));
    final created = updated.items.firstWhere((i) => i.id == newItem.id);
    await _publishAdded(updated, created);
    return created;
  }

  @override
  Future<({String focusItemId, int cursor})> mergeItem(
      String categoryId, String itemId) async {
    await _ready();
    final category = _requireCategory(categoryId);
    final result = category.mergeWithPrevious(itemId);
    await _commit(_list.replaceCategory(result.category));
    return (focusItemId: result.focusItemId, cursor: result.cursor);
  }

  @override
  Future<void> clearBought(String categoryId) async {
    await _ready();
    final category = _requireCategory(categoryId);
    await _commit(_list.replaceCategory(category.clearBought()));
  }

  @override
  Future<void> clearEmpty(String categoryId) async {
    await _ready();
    final category = _list.categoryById(categoryId);
    if (category == null || !category.hasEmptyItems) return; // rien à purger
    await _commit(_list.replaceCategory(category.removeEmptyItems()));
  }

  void dispose() => _controller.close();
}
