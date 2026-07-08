import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/shopping_list.dart';

/// Persistance locale de la liste (JSON dans `shared_preferences`), clé par
/// maison. Local = source de vérité (offline-first).
class ShoppingLocalDatasource {
  ShoppingLocalDatasource(this._prefs);

  final SharedPreferences _prefs;

  static String _key(String householdId) => 'shopping_list_$householdId';

  ShoppingList? load(String householdId) {
    final raw = _prefs.getString(_key(householdId));
    if (raw == null) return null;
    return ShoppingList.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(ShoppingList list) =>
      _prefs.setString(_key(list.householdId), jsonEncode(list.toJson()));
}
