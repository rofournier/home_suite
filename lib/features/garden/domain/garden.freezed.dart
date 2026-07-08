// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'garden.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Garden {

 String get householdId; List<Plant> get plants; DateTime? get updatedAt;
/// Create a copy of Garden
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GardenCopyWith<Garden> get copyWith => _$GardenCopyWithImpl<Garden>(this as Garden, _$identity);

  /// Serializes this Garden to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Garden&&(identical(other.householdId, householdId) || other.householdId == householdId)&&const DeepCollectionEquality().equals(other.plants, plants)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,householdId,const DeepCollectionEquality().hash(plants),updatedAt);

@override
String toString() {
  return 'Garden(householdId: $householdId, plants: $plants, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $GardenCopyWith<$Res>  {
  factory $GardenCopyWith(Garden value, $Res Function(Garden) _then) = _$GardenCopyWithImpl;
@useResult
$Res call({
 String householdId, List<Plant> plants, DateTime? updatedAt
});




}
/// @nodoc
class _$GardenCopyWithImpl<$Res>
    implements $GardenCopyWith<$Res> {
  _$GardenCopyWithImpl(this._self, this._then);

  final Garden _self;
  final $Res Function(Garden) _then;

/// Create a copy of Garden
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? householdId = null,Object? plants = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,plants: null == plants ? _self.plants : plants // ignore: cast_nullable_to_non_nullable
as List<Plant>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Garden].
extension GardenPatterns on Garden {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Garden value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Garden() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Garden value)  $default,){
final _that = this;
switch (_that) {
case _Garden():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Garden value)?  $default,){
final _that = this;
switch (_that) {
case _Garden() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String householdId,  List<Plant> plants,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Garden() when $default != null:
return $default(_that.householdId,_that.plants,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String householdId,  List<Plant> plants,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Garden():
return $default(_that.householdId,_that.plants,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String householdId,  List<Plant> plants,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Garden() when $default != null:
return $default(_that.householdId,_that.plants,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Garden extends Garden {
  const _Garden({required this.householdId, final  List<Plant> plants = const <Plant>[], this.updatedAt}): _plants = plants,super._();
  factory _Garden.fromJson(Map<String, dynamic> json) => _$GardenFromJson(json);

@override final  String householdId;
 final  List<Plant> _plants;
@override@JsonKey() List<Plant> get plants {
  if (_plants is EqualUnmodifiableListView) return _plants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_plants);
}

@override final  DateTime? updatedAt;

/// Create a copy of Garden
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GardenCopyWith<_Garden> get copyWith => __$GardenCopyWithImpl<_Garden>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GardenToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Garden&&(identical(other.householdId, householdId) || other.householdId == householdId)&&const DeepCollectionEquality().equals(other._plants, _plants)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,householdId,const DeepCollectionEquality().hash(_plants),updatedAt);

@override
String toString() {
  return 'Garden(householdId: $householdId, plants: $plants, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GardenCopyWith<$Res> implements $GardenCopyWith<$Res> {
  factory _$GardenCopyWith(_Garden value, $Res Function(_Garden) _then) = __$GardenCopyWithImpl;
@override @useResult
$Res call({
 String householdId, List<Plant> plants, DateTime? updatedAt
});




}
/// @nodoc
class __$GardenCopyWithImpl<$Res>
    implements _$GardenCopyWith<$Res> {
  __$GardenCopyWithImpl(this._self, this._then);

  final _Garden _self;
  final $Res Function(_Garden) _then;

/// Create a copy of Garden
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? householdId = null,Object? plants = null,Object? updatedAt = freezed,}) {
  return _then(_Garden(
householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,plants: null == plants ? _self._plants : plants // ignore: cast_nullable_to_non_nullable
as List<Plant>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
