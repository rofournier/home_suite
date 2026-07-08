import 'package:freezed_annotation/freezed_annotation.dart';

import 'gallery_item.dart';

part 'gallery_album.freezed.dart';
part 'gallery_album.g.dart';

/// Agrégat persisté d'une maison : ses dessins, du plus récent au plus ancien
/// (ordre d'insertion en tête). LWW via `updatedAt`, comme les autres agrégats.
@freezed
abstract class GalleryAlbum with _$GalleryAlbum {
  const factory GalleryAlbum({
    required String householdId,
    @Default(<GalleryItem>[]) List<GalleryItem> items,
    DateTime? updatedAt,
  }) = _GalleryAlbum;
  const GalleryAlbum._();

  factory GalleryAlbum.fromJson(Map<String, dynamic> json) =>
      _$GalleryAlbumFromJson(json);

  GalleryItem? itemById(String id) {
    final i = items.indexWhere((d) => d.id == id);
    return i < 0 ? null : items[i];
  }

  /// Insère en tête : la galerie s'affiche du plus récent au plus ancien.
  GalleryAlbum addItem(GalleryItem item) => copyWith(items: [item, ...items]);

  GalleryAlbum removeItem(String id) =>
      copyWith(items: items.where((d) => d.id != id).toList());
}
