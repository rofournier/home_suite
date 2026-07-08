import 'package:freezed_annotation/freezed_annotation.dart';

part 'shopping_item.freezed.dart';
part 'shopping_item.g.dart';

/// Un article de la liste de courses. L'ordre est porté par la position dans
/// la liste de la catégorie (pas de champ `position` à réindexer).
/// `createdBy` = id du membre auteur, alimente la notif temps réel.
/// Sérialisable = futur DTO serveur.
@freezed
abstract class ShoppingItem with _$ShoppingItem {
  const factory ShoppingItem({
    required String id,
    required String text,
    @Default(false) bool bought,
    required String createdBy,
    required DateTime createdAt,
  }) = _ShoppingItem;

  factory ShoppingItem.fromJson(Map<String, dynamic> json) =>
      _$ShoppingItemFromJson(json);
}
