// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_tab.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentTab _$DocumentTabFromJson(Map<String, dynamic> json) => _DocumentTab(
  id: json['id'] as String,
  name: json['name'] as String,
  documents:
      (json['documents'] as List<dynamic>?)
          ?.map((e) => Document.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Document>[],
);

Map<String, dynamic> _$DocumentTabToJson(_DocumentTab instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'documents': instance.documents.map((e) => e.toJson()).toList(),
    };
