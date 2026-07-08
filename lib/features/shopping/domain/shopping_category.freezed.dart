// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shopping_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShoppingCategory {

 String get id; String get name; List<ShoppingItem> get items;
/// Create a copy of ShoppingCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShoppingCategoryCopyWith<ShoppingCategory> get copyWith => _$ShoppingCategoryCopyWithImpl<ShoppingCategory>(this as ShoppingCategory, _$identity);

  /// Serializes this ShoppingCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShoppingCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'ShoppingCategory(id: $id, name: $name, items: $items)';
}


}

/// @nodoc
abstract mixin class $ShoppingCategoryCopyWith<$Res>  {
  factory $ShoppingCategoryCopyWith(ShoppingCategory value, $Res Function(ShoppingCategory) _then) = _$ShoppingCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<ShoppingItem> items
});




}
/// @nodoc
class _$ShoppingCategoryCopyWithImpl<$Res>
    implements $ShoppingCategoryCopyWith<$Res> {
  _$ShoppingCategoryCopyWithImpl(this._self, this._then);

  final ShoppingCategory _self;
  final $Res Function(ShoppingCategory) _then;

/// Create a copy of ShoppingCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ShoppingItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [ShoppingCategory].
extension ShoppingCategoryPatterns on ShoppingCategory {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShoppingCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShoppingCategory() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShoppingCategory value)  $default,){
final _that = this;
switch (_that) {
case _ShoppingCategory():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShoppingCategory value)?  $default,){
final _that = this;
switch (_that) {
case _ShoppingCategory() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<ShoppingItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShoppingCategory() when $default != null:
return $default(_that.id,_that.name,_that.items);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<ShoppingItem> items)  $default,) {final _that = this;
switch (_that) {
case _ShoppingCategory():
return $default(_that.id,_that.name,_that.items);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<ShoppingItem> items)?  $default,) {final _that = this;
switch (_that) {
case _ShoppingCategory() when $default != null:
return $default(_that.id,_that.name,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShoppingCategory extends ShoppingCategory {
  const _ShoppingCategory({required this.id, required this.name, final  List<ShoppingItem> items = const <ShoppingItem>[]}): _items = items,super._();
  factory _ShoppingCategory.fromJson(Map<String, dynamic> json) => _$ShoppingCategoryFromJson(json);

@override final  String id;
@override final  String name;
 final  List<ShoppingItem> _items;
@override@JsonKey() List<ShoppingItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of ShoppingCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShoppingCategoryCopyWith<_ShoppingCategory> get copyWith => __$ShoppingCategoryCopyWithImpl<_ShoppingCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShoppingCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShoppingCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'ShoppingCategory(id: $id, name: $name, items: $items)';
}


}

/// @nodoc
abstract mixin class _$ShoppingCategoryCopyWith<$Res> implements $ShoppingCategoryCopyWith<$Res> {
  factory _$ShoppingCategoryCopyWith(_ShoppingCategory value, $Res Function(_ShoppingCategory) _then) = __$ShoppingCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<ShoppingItem> items
});




}
/// @nodoc
class __$ShoppingCategoryCopyWithImpl<$Res>
    implements _$ShoppingCategoryCopyWith<$Res> {
  __$ShoppingCategoryCopyWithImpl(this._self, this._then);

  final _ShoppingCategory _self;
  final $Res Function(_ShoppingCategory) _then;

/// Create a copy of ShoppingCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? items = null,}) {
  return _then(_ShoppingCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ShoppingItem>,
  ));
}


}

// dart format on
