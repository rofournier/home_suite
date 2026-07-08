// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garden.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Garden _$GardenFromJson(Map<String, dynamic> json) => _Garden(
  householdId: json['householdId'] as String,
  plants:
      (json['plants'] as List<dynamic>?)
          ?.map((e) => Plant.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Plant>[],
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$GardenToJson(_Garden instance) => <String, dynamic>{
  'householdId': instance.householdId,
  'plants': instance.plants.map((e) => e.toJson()).toList(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
