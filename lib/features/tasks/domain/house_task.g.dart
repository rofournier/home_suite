// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'house_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HouseTask _$HouseTaskFromJson(Map<String, dynamic> json) => _HouseTask(
  id: json['id'] as String,
  category: $enumDecode(_$TaskCategoryEnumMap, json['category']),
  severity: (json['severity'] as num).toInt(),
  room: $enumDecode(_$RoomEnumMap, json['room']),
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  completedBy: json['completedBy'] as String?,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$HouseTaskToJson(_HouseTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': _$TaskCategoryEnumMap[instance.category]!,
      'severity': instance.severity,
      'room': _$RoomEnumMap[instance.room]!,
      'x': instance.x,
      'y': instance.y,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedBy': instance.completedBy,
      'completedAt': instance.completedAt?.toIso8601String(),
    };

const _$TaskCategoryEnumMap = {
  TaskCategory.vaisselle: 'vaisselle',
  TaskCategory.litiere: 'litiere',
  TaskCategory.aspi: 'aspi',
  TaskCategory.poussiere: 'poussiere',
  TaskCategory.chaussettes: 'chaussettes',
  TaskCategory.fourmis: 'fourmis',
  TaskCategory.linge: 'linge',
  TaskCategory.autre: 'autre',
  TaskCategory.poubelle: 'poubelle',
  TaskCategory.vitres: 'vitres',
  TaskCategory.plantes: 'plantes',
  TaskCategory.nettoyage: 'nettoyage',
};

const _$RoomEnumMap = {
  Room.cuisine: 'cuisine',
  Room.salon: 'salon',
  Room.chambreSuleyman: 'chambreSuleyman',
  Room.chambreParents: 'chambreParents',
  Room.salleDeBains: 'salleDeBains',
  Room.balcon: 'balcon',
  Room.couloir: 'couloir',
};
