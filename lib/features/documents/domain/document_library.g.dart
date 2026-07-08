// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_library.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentLibrary _$DocumentLibraryFromJson(Map<String, dynamic> json) =>
    _DocumentLibrary(
      householdId: json['householdId'] as String,
      tabs:
          (json['tabs'] as List<dynamic>?)
              ?.map((e) => DocumentTab.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DocumentTab>[],
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DocumentLibraryToJson(_DocumentLibrary instance) =>
    <String, dynamic>{
      'householdId': instance.householdId,
      'tabs': instance.tabs.map((e) => e.toJson()).toList(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
