// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Plant _$PlantFromJson(Map<String, dynamic> json) => _Plant(
  id: json['id'] as String,
  name: json['name'] as String,
  room: $enumDecode(_$RoomEnumMap, json['room']),
  photoPath: json['photoPath'] as String?,
  fileId: json['fileId'] as String?,
  waterEveryDays: (json['waterEveryDays'] as num).toInt(),
  lastWateredAt: json['lastWateredAt'] == null
      ? null
      : DateTime.parse(json['lastWateredAt'] as String),
  lastWateredBy: json['lastWateredBy'] as String?,
  feedEveryDays: (json['feedEveryDays'] as num?)?.toInt(),
  lastFedAt: json['lastFedAt'] == null
      ? null
      : DateTime.parse(json['lastFedAt'] as String),
  lastFedBy: json['lastFedBy'] as String?,
  note: json['note'] as String? ?? '',
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  history:
      (json['history'] as List<dynamic>?)
          ?.map((e) => WateringEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <WateringEntry>[],
  feedHistory:
      (json['feedHistory'] as List<dynamic>?)
          ?.map((e) => WateringEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <WateringEntry>[],
);

Map<String, dynamic> _$PlantToJson(_Plant instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'room': _$RoomEnumMap[instance.room]!,
  'photoPath': instance.photoPath,
  'fileId': instance.fileId,
  'waterEveryDays': instance.waterEveryDays,
  'lastWateredAt': instance.lastWateredAt?.toIso8601String(),
  'lastWateredBy': instance.lastWateredBy,
  'feedEveryDays': instance.feedEveryDays,
  'lastFedAt': instance.lastFedAt?.toIso8601String(),
  'lastFedBy': instance.lastFedBy,
  'note': instance.note,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'history': instance.history.map((e) => e.toJson()).toList(),
  'feedHistory': instance.feedHistory.map((e) => e.toJson()).toList(),
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

_WateringEntry _$WateringEntryFromJson(Map<String, dynamic> json) =>
    _WateringEntry(
      by: json['by'] as String,
      at: DateTime.parse(json['at'] as String),
    );

Map<String, dynamic> _$WateringEntryToJson(_WateringEntry instance) =>
    <String, dynamic>{'by': instance.by, 'at': instance.at.toIso8601String()};
