import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/task_board.dart';

/// Persistance locale du board de tâches (JSON) par maison.
class TaskLocalDatasource {
  const TaskLocalDatasource(this._prefs);

  final SharedPreferences _prefs;

  String _key(String householdId) => 'tasks_$householdId';

  TaskBoard? load(String householdId) {
    final raw = _prefs.getString(_key(householdId));
    if (raw == null) return null;
    return TaskBoard.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(TaskBoard board) =>
      _prefs.setString(_key(board.householdId), jsonEncode(board.toJson()));
}
