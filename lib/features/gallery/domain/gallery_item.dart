import 'package:freezed_annotation/freezed_annotation.dart';

part 'gallery_item.freezed.dart';
part 'gallery_item.g.dart';

/// Un dessin de la galerie. `imagePath` = copie locale (auteur) ;
/// `fileId` = binaire uploadé (null tant que l'upload n'a pas abouti).
@freezed
abstract class GalleryItem with _$GalleryItem {
  const factory GalleryItem({
    required String id,
    required String title,
    required String imagePath,
    String? fileId,
    required String createdBy,
    required DateTime createdAt,
  }) = _GalleryItem;

  factory GalleryItem.fromJson(Map<String, dynamic> json) =>
      _$GalleryItemFromJson(json);
}
