// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_board.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemberScore _$MemberScoreFromJson(Map<String, dynamic> json) => _MemberScore(
  memberId: json['memberId'] as String,
  points: (json['points'] as num?)?.toInt() ?? 0,
  completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
  createdCount: (json['createdCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MemberScoreToJson(_MemberScore instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'points': instance.points,
      'completedCount': instance.completedCount,
      'createdCount': instance.createdCount,
    };

_TaskBoard _$TaskBoardFromJson(Map<String, dynamic> json) => _TaskBoard(
  householdId: json['householdId'] as String,
  tasks:
      (json['tasks'] as List<dynamic>?)
          ?.map((e) => HouseTask.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <HouseTask>[],
  scores:
      (json['scores'] as List<dynamic>?)
          ?.map((e) => MemberScore.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MemberScore>[],
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TaskBoardToJson(_TaskBoard instance) =>
    <String, dynamic>{
      'householdId': instance.householdId,
      'tasks': instance.tasks.map((e) => e.toJson()).toList(),
      'scores': instance.scores.map((e) => e.toJson()).toList(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
