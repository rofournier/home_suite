// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'house_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HouseTask {

 String get id; TaskCategory get category; int get severity; Room get room; double get x; double get y; String get createdBy; DateTime get createdAt; String? get completedBy; DateTime? get completedAt;
/// Create a copy of HouseTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseTaskCopyWith<HouseTask> get copyWith => _$HouseTaskCopyWithImpl<HouseTask>(this as HouseTask, _$identity);

  /// Serializes this HouseTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseTask&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.room, room) || other.room == room)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedBy, completedBy) || other.completedBy == completedBy)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,severity,room,x,y,createdBy,createdAt,completedBy,completedAt);

@override
String toString() {
  return 'HouseTask(id: $id, category: $category, severity: $severity, room: $room, x: $x, y: $y, createdBy: $createdBy, createdAt: $createdAt, completedBy: $completedBy, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $HouseTaskCopyWith<$Res>  {
  factory $HouseTaskCopyWith(HouseTask value, $Res Function(HouseTask) _then) = _$HouseTaskCopyWithImpl;
@useResult
$Res call({
 String id, TaskCategory category, int severity, Room room, double x, double y, String createdBy, DateTime createdAt, String? completedBy, DateTime? completedAt
});




}
/// @nodoc
class _$HouseTaskCopyWithImpl<$Res>
    implements $HouseTaskCopyWith<$Res> {
  _$HouseTaskCopyWithImpl(this._self, this._then);

  final HouseTask _self;
  final $Res Function(HouseTask) _then;

/// Create a copy of HouseTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? category = null,Object? severity = null,Object? room = null,Object? x = null,Object? y = null,Object? createdBy = null,Object? createdAt = null,Object? completedBy = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TaskCategory,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as int,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as Room,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedBy: freezed == completedBy ? _self.completedBy : completedBy // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [HouseTask].
extension HouseTaskPatterns on HouseTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseTask value)  $default,){
final _that = this;
switch (_that) {
case _HouseTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseTask value)?  $default,){
final _that = this;
switch (_that) {
case _HouseTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TaskCategory category,  int severity,  Room room,  double x,  double y,  String createdBy,  DateTime createdAt,  String? completedBy,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseTask() when $default != null:
return $default(_that.id,_that.category,_that.severity,_that.room,_that.x,_that.y,_that.createdBy,_that.createdAt,_that.completedBy,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TaskCategory category,  int severity,  Room room,  double x,  double y,  String createdBy,  DateTime createdAt,  String? completedBy,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _HouseTask():
return $default(_that.id,_that.category,_that.severity,_that.room,_that.x,_that.y,_that.createdBy,_that.createdAt,_that.completedBy,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TaskCategory category,  int severity,  Room room,  double x,  double y,  String createdBy,  DateTime createdAt,  String? completedBy,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _HouseTask() when $default != null:
return $default(_that.id,_that.category,_that.severity,_that.room,_that.x,_that.y,_that.createdBy,_that.createdAt,_that.completedBy,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HouseTask extends HouseTask {
  const _HouseTask({required this.id, required this.category, required this.severity, required this.room, required this.x, required this.y, required this.createdBy, required this.createdAt, this.completedBy, this.completedAt}): super._();
  factory _HouseTask.fromJson(Map<String, dynamic> json) => _$HouseTaskFromJson(json);

@override final  String id;
@override final  TaskCategory category;
@override final  int severity;
@override final  Room room;
@override final  double x;
@override final  double y;
@override final  String createdBy;
@override final  DateTime createdAt;
@override final  String? completedBy;
@override final  DateTime? completedAt;

/// Create a copy of HouseTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseTaskCopyWith<_HouseTask> get copyWith => __$HouseTaskCopyWithImpl<_HouseTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseTask&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.room, room) || other.room == room)&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedBy, completedBy) || other.completedBy == completedBy)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,severity,room,x,y,createdBy,createdAt,completedBy,completedAt);

@override
String toString() {
  return 'HouseTask(id: $id, category: $category, severity: $severity, room: $room, x: $x, y: $y, createdBy: $createdBy, createdAt: $createdAt, completedBy: $completedBy, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$HouseTaskCopyWith<$Res> implements $HouseTaskCopyWith<$Res> {
  factory _$HouseTaskCopyWith(_HouseTask value, $Res Function(_HouseTask) _then) = __$HouseTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, TaskCategory category, int severity, Room room, double x, double y, String createdBy, DateTime createdAt, String? completedBy, DateTime? completedAt
});




}
/// @nodoc
class __$HouseTaskCopyWithImpl<$Res>
    implements _$HouseTaskCopyWith<$Res> {
  __$HouseTaskCopyWithImpl(this._self, this._then);

  final _HouseTask _self;
  final $Res Function(_HouseTask) _then;

/// Create a copy of HouseTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? category = null,Object? severity = null,Object? room = null,Object? x = null,Object? y = null,Object? createdBy = null,Object? createdAt = null,Object? completedBy = freezed,Object? completedAt = freezed,}) {
  return _then(_HouseTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TaskCategory,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as int,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as Room,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedBy: freezed == completedBy ? _self.completedBy : completedBy // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
