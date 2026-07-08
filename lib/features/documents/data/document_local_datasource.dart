import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/document_library.dart';

/// Persistance locale des métadonnées documents (JSON) par maison. Les images
/// vivent sur disque (voir [LocalImageStore]) ; ici seules les métadonnées.
class DocumentLocalDatasource {
  const DocumentLocalDatasource(this._prefs);

  final SharedPreferences _prefs;

  String _key(String householdId) => 'documents_$householdId';

  DocumentLibrary? load(String householdId) {
    final raw = _prefs.getString(_key(householdId));
    if (raw == null) return null;
    return DocumentLibrary.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(DocumentLibrary library) => _prefs.setString(
        _key(library.householdId),
        jsonEncode(library.toJson()),
      );
}
