import 'dart:convert';

import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

/// Accès SQLite. Source de vérité serveur : users, households, et la liste de
/// courses stockée en un blob JSON par maison (LWW, suffisant pour un foyer).
class Db {
  Db(this._db) {
    _migrate();
  }

  final Database _db;
  static const _uuid = Uuid();

  factory Db.open(String path) => Db(sqlite3.open(path));

  void dispose() => _db.dispose();

  void _migrate() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS households (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        join_code TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL
      );
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        display_name TEXT NOT NULL,
        household_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (household_id) REFERENCES households (id)
      );
      CREATE TABLE IF NOT EXISTS shopping_lists (
        household_id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
      CREATE TABLE IF NOT EXISTS document_libraries (
        household_id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
      CREATE TABLE IF NOT EXISTS task_boards (
        household_id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
      CREATE TABLE IF NOT EXISTS gallery_albums (
        household_id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
      CREATE TABLE IF NOT EXISTS gardens (
        household_id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');
  }

  // --- Households -----------------------------------------------------------

  Map<String, Object?>? householdById(String id) =>
      _one('SELECT * FROM households WHERE id = ?', [id]);

  Map<String, Object?>? householdByJoinCode(String code) =>
      _one('SELECT * FROM households WHERE join_code = ?', [code]);

  /// Crée une maison avec un code d'invitation court et unique.
  Map<String, Object?> createHousehold(String name, String nowIso) {
    final id = _uuid.v4();
    final code = _freshJoinCode();
    _db.execute(
      'INSERT INTO households (id, name, join_code, created_at) VALUES (?, ?, ?, ?)',
      [id, name, code, nowIso],
    );
    return householdById(id)!;
  }

  String _freshJoinCode() {
    // Boucle courte : code à 6 caractères, réessaie en cas de collision rare.
    for (var attempt = 0; attempt < 8; attempt++) {
      final code = _uuid.v4().replaceAll('-', '').substring(0, 6).toUpperCase();
      if (householdByJoinCode(code) == null) return code;
    }
    throw StateError('Impossible de générer un code de maison unique');
  }

  List<Map<String, Object?>> membersOf(String householdId) => _all(
        'SELECT id, display_name FROM users WHERE household_id = ? ORDER BY created_at',
        [householdId],
      );

  // --- Users ----------------------------------------------------------------

  Map<String, Object?>? userByEmail(String email) =>
      _one('SELECT * FROM users WHERE email = ?', [email.toLowerCase()]);

  Map<String, Object?>? userById(String id) =>
      _one('SELECT * FROM users WHERE id = ?', [id]);

  Map<String, Object?> createUser({
    required String email,
    required String passwordHash,
    required String displayName,
    required String householdId,
    required String nowIso,
  }) {
    final id = _uuid.v4();
    _db.execute(
      'INSERT INTO users (id, email, password_hash, display_name, household_id, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      [id, email.toLowerCase(), passwordHash, displayName, householdId, nowIso],
    );
    return userById(id)!;
  }

  // --- Shopping list (blob JSON par maison) ---------------------------------

  Map<String, dynamic>? shoppingList(String householdId) {
    final row = _one(
      'SELECT data FROM shopping_lists WHERE household_id = ?',
      [householdId],
    );
    if (row == null) return null;
    return jsonDecode(row['data'] as String) as Map<String, dynamic>;
  }

  void saveShoppingList(
      String householdId, Map<String, dynamic> list, String nowIso) {
    _db.execute(
      'INSERT INTO shopping_lists (household_id, data, updated_at) VALUES (?, ?, ?) '
      'ON CONFLICT(household_id) DO UPDATE SET data = excluded.data, updated_at = excluded.updated_at',
      [householdId, jsonEncode(list), nowIso],
    );
  }

  // --- Document library (blob JSON par maison) -------------------------------

  Map<String, dynamic>? documentLibrary(String householdId) {
    final row = _one(
      'SELECT data FROM document_libraries WHERE household_id = ?',
      [householdId],
    );
    if (row == null) return null;
    return jsonDecode(row['data'] as String) as Map<String, dynamic>;
  }

  void saveDocumentLibrary(
      String householdId, Map<String, dynamic> library, String nowIso) {
    _db.execute(
      'INSERT INTO document_libraries (household_id, data, updated_at) VALUES (?, ?, ?) '
      'ON CONFLICT(household_id) DO UPDATE SET data = excluded.data, updated_at = excluded.updated_at',
      [householdId, jsonEncode(library), nowIso],
    );
  }

  // --- Task board (blob JSON par maison) --------------------------------------

  Map<String, dynamic>? taskBoard(String householdId) {
    final row = _one(
      'SELECT data FROM task_boards WHERE household_id = ?',
      [householdId],
    );
    if (row == null) return null;
    return jsonDecode(row['data'] as String) as Map<String, dynamic>;
  }

  void saveTaskBoard(
      String householdId, Map<String, dynamic> board, String nowIso) {
    _db.execute(
      'INSERT INTO task_boards (household_id, data, updated_at) VALUES (?, ?, ?) '
      'ON CONFLICT(household_id) DO UPDATE SET data = excluded.data, updated_at = excluded.updated_at',
      [householdId, jsonEncode(board), nowIso],
    );
  }

  // --- Gallery album (blob JSON par maison) -----------------------------------

  Map<String, dynamic>? galleryAlbum(String householdId) {
    final row = _one(
      'SELECT data FROM gallery_albums WHERE household_id = ?',
      [householdId],
    );
    if (row == null) return null;
    return jsonDecode(row['data'] as String) as Map<String, dynamic>;
  }

  void saveGalleryAlbum(
      String householdId, Map<String, dynamic> album, String nowIso) {
    _db.execute(
      'INSERT INTO gallery_albums (household_id, data, updated_at) VALUES (?, ?, ?) '
      'ON CONFLICT(household_id) DO UPDATE SET data = excluded.data, updated_at = excluded.updated_at',
      [householdId, jsonEncode(album), nowIso],
    );
  }

  // --- Garden (blob JSON par maison) ------------------------------------------

  Map<String, dynamic>? garden(String householdId) {
    final row = _one(
      'SELECT data FROM gardens WHERE household_id = ?',
      [householdId],
    );
    if (row == null) return null;
    return jsonDecode(row['data'] as String) as Map<String, dynamic>;
  }

  void saveGarden(
      String householdId, Map<String, dynamic> garden, String nowIso) {
    _db.execute(
      'INSERT INTO gardens (household_id, data, updated_at) VALUES (?, ?, ?) '
      'ON CONFLICT(household_id) DO UPDATE SET data = excluded.data, updated_at = excluded.updated_at',
      [householdId, jsonEncode(garden), nowIso],
    );
  }

  // --- Helpers --------------------------------------------------------------

  Map<String, Object?>? _one(String sql, List<Object?> args) {
    final rows = _db.select(sql, args);
    return rows.isEmpty ? null : rows.first;
  }

  List<Map<String, Object?>> _all(String sql, List<Object?> args) =>
      _db.select(sql, args).toList();
}
