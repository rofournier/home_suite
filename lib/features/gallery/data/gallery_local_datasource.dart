import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/gallery_album.dart';

/// Persistance locale des métadonnées galerie (JSON) par maison.
class GalleryLocalDatasource {
  const GalleryLocalDatasource(this._prefs);

  final SharedPreferences _prefs;

  String _key(String householdId) => 'gallery_$householdId';

  GalleryAlbum? load(String householdId) {
    final raw = _prefs.getString(_key(householdId));
    if (raw == null) return null;
    return GalleryAlbum.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(GalleryAlbum album) =>
      _prefs.setString(_key(album.householdId), jsonEncode(album.toJson()));
}
