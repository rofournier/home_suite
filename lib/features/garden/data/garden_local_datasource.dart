import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/garden.dart';

/// Persistance locale du jardin (JSON) par maison.
class GardenLocalDatasource {
  const GardenLocalDatasource(this._prefs);

  final SharedPreferences _prefs;

  String _key(String householdId) => 'garden_$householdId';

  Garden? load(String householdId) {
    final raw = _prefs.getString(_key(householdId));
    if (raw == null) return null;
    return Garden.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(Garden garden) =>
      _prefs.setString(_key(garden.householdId), jsonEncode(garden.toJson()));
}
