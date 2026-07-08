// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShoppingList _$ShoppingListFromJson(Map<String, dynamic> json) =>
    _ShoppingList(
      householdId: json['householdId'] as String,
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => ShoppingCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ShoppingCategory>[],
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ShoppingListToJson(_ShoppingList instance) =>
    <String, dynamic>{
      'householdId': instance.householdId,
      'categories': instance.categories.map((e) => e.toJson()).toList(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
