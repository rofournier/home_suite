// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Document _$DocumentFromJson(Map<String, dynamic> json) => _Document(
  id: json['id'] as String,
  tabId: json['tabId'] as String,
  title: json['title'] as String,
  imagePath: json['imagePath'] as String,
  fileId: json['fileId'] as String?,
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$DocumentToJson(_Document instance) => <String, dynamic>{
  'id': instance.id,
  'tabId': instance.tabId,
  'title': instance.title,
  'imagePath': instance.imagePath,
  'fileId': instance.fileId,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
};
