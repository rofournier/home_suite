// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gallery_album.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GalleryAlbum {

 String get householdId; List<GalleryItem> get items; DateTime? get updatedAt;
/// Create a copy of GalleryAlbum
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GalleryAlbumCopyWith<GalleryAlbum> get copyWith => _$GalleryAlbumCopyWithImpl<GalleryAlbum>(this as GalleryAlbum, _$identity);

  /// Serializes this GalleryAlbum to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GalleryAlbum&&(identical(other.householdId, householdId) || other.householdId == householdId)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,householdId,const DeepCollectionEquality().hash(items),updatedAt);

@override
String toString() {
  return 'GalleryAlbum(householdId: $householdId, items: $items, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $GalleryAlbumCopyWith<$Res>  {
  factory $GalleryAlbumCopyWith(GalleryAlbum value, $Res Function(GalleryAlbum) _then) = _$GalleryAlbumCopyWithImpl;
@useResult
$Res call({
 String householdId, List<GalleryItem> items, DateTime? updatedAt
});




}
/// @nodoc
class _$GalleryAlbumCopyWithImpl<$Res>
    implements $GalleryAlbumCopyWith<$Res> {
  _$GalleryAlbumCopyWithImpl(this._self, this._then);

  final GalleryAlbum _self;
  final $Res Function(GalleryAlbum) _then;

/// Create a copy of GalleryAlbum
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? householdId = null,Object? items = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<GalleryItem>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GalleryAlbum].
extension GalleryAlbumPatterns on GalleryAlbum {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GalleryAlbum value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GalleryAlbum() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GalleryAlbum value)  $default,){
final _that = this;
switch (_that) {
case _GalleryAlbum():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GalleryAlbum value)?  $default,){
final _that = this;
switch (_that) {
case _GalleryAlbum() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String householdId,  List<GalleryItem> items,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GalleryAlbum() when $default != null:
return $default(_that.householdId,_that.items,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String householdId,  List<GalleryItem> items,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _GalleryAlbum():
return $default(_that.householdId,_that.items,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String householdId,  List<GalleryItem> items,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _GalleryAlbum() when $default != null:
return $default(_that.householdId,_that.items,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GalleryAlbum extends GalleryAlbum {
  const _GalleryAlbum({required this.householdId, final  List<GalleryItem> items = const <GalleryItem>[], this.updatedAt}): _items = items,super._();
  factory _GalleryAlbum.fromJson(Map<String, dynamic> json) => _$GalleryAlbumFromJson(json);

@override final  String householdId;
 final  List<GalleryItem> _items;
@override@JsonKey() List<GalleryItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  DateTime? updatedAt;

/// Create a copy of GalleryAlbum
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GalleryAlbumCopyWith<_GalleryAlbum> get copyWith => __$GalleryAlbumCopyWithImpl<_GalleryAlbum>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GalleryAlbumToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GalleryAlbum&&(identical(other.householdId, householdId) || other.householdId == householdId)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,householdId,const DeepCollectionEquality().hash(_items),updatedAt);

@override
String toString() {
  return 'GalleryAlbum(householdId: $householdId, items: $items, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GalleryAlbumCopyWith<$Res> implements $GalleryAlbumCopyWith<$Res> {
  factory _$GalleryAlbumCopyWith(_GalleryAlbum value, $Res Function(_GalleryAlbum) _then) = __$GalleryAlbumCopyWithImpl;
@override @useResult
$Res call({
 String householdId, List<GalleryItem> items, DateTime? updatedAt
});




}
/// @nodoc
class __$GalleryAlbumCopyWithImpl<$Res>
    implements _$GalleryAlbumCopyWith<$Res> {
  __$GalleryAlbumCopyWithImpl(this._self, this._then);

  final _GalleryAlbum _self;
  final $Res Function(_GalleryAlbum) _then;

/// Create a copy of GalleryAlbum
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? householdId = null,Object? items = null,Object? updatedAt = freezed,}) {
  return _then(_GalleryAlbum(
householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<GalleryItem>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
