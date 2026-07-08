// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GalleryAlbum _$GalleryAlbumFromJson(Map<String, dynamic> json) =>
    _GalleryAlbum(
      householdId: json['householdId'] as String,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => GalleryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <GalleryItem>[],
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$GalleryAlbumToJson(_GalleryAlbum instance) =>
    <String, dynamic>{
      'householdId': instance.householdId,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
