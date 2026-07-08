// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShoppingCategory _$ShoppingCategoryFromJson(Map<String, dynamic> json) =>
    _ShoppingCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ShoppingItem>[],
    );

Map<String, dynamic> _$ShoppingCategoryToJson(_ShoppingCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };
