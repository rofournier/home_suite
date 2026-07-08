// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Plant {

 String get id; String get name; Room get room; String? get photoPath; String? get fileId; int get waterEveryDays; DateTime? get lastWateredAt; String? get lastWateredBy; int? get feedEveryDays; DateTime? get lastFedAt; String? get lastFedBy; String get note; String get createdBy; DateTime get createdAt; List<WateringEntry> get history; List<WateringEntry> get feedHistory;
/// Create a copy of Plant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlantCopyWith<Plant> get copyWith => _$PlantCopyWithImpl<Plant>(this as Plant, _$identity);

  /// Serializes this Plant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Plant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.room, room) || other.room == room)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.waterEveryDays, waterEveryDays) || other.waterEveryDays == waterEveryDays)&&(identical(other.lastWateredAt, lastWateredAt) || other.lastWateredAt == lastWateredAt)&&(identical(other.lastWateredBy, lastWateredBy) || other.lastWateredBy == lastWateredBy)&&(identical(other.feedEveryDays, feedEveryDays) || other.feedEveryDays == feedEveryDays)&&(identical(other.lastFedAt, lastFedAt) || other.lastFedAt == lastFedAt)&&(identical(other.lastFedBy, lastFedBy) || other.lastFedBy == lastFedBy)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.history, history)&&const DeepCollectionEquality().equals(other.feedHistory, feedHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,room,photoPath,fileId,waterEveryDays,lastWateredAt,lastWateredBy,feedEveryDays,lastFedAt,lastFedBy,note,createdBy,createdAt,const DeepCollectionEquality().hash(history),const DeepCollectionEquality().hash(feedHistory));

@override
String toString() {
  return 'Plant(id: $id, name: $name, room: $room, photoPath: $photoPath, fileId: $fileId, waterEveryDays: $waterEveryDays, lastWateredAt: $lastWateredAt, lastWateredBy: $lastWateredBy, feedEveryDays: $feedEveryDays, lastFedAt: $lastFedAt, lastFedBy: $lastFedBy, note: $note, createdBy: $createdBy, createdAt: $createdAt, history: $history, feedHistory: $feedHistory)';
}


}

/// @nodoc
abstract mixin class $PlantCopyWith<$Res>  {
  factory $PlantCopyWith(Plant value, $Res Function(Plant) _then) = _$PlantCopyWithImpl;
@useResult
$Res call({
 String id, String name, Room room, String? photoPath, String? fileId, int waterEveryDays, DateTime? lastWateredAt, String? lastWateredBy, int? feedEveryDays, DateTime? lastFedAt, String? lastFedBy, String note, String createdBy, DateTime createdAt, List<WateringEntry> history, List<WateringEntry> feedHistory
});




}
/// @nodoc
class _$PlantCopyWithImpl<$Res>
    implements $PlantCopyWith<$Res> {
  _$PlantCopyWithImpl(this._self, this._then);

  final Plant _self;
  final $Res Function(Plant) _then;

/// Create a copy of Plant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? room = null,Object? photoPath = freezed,Object? fileId = freezed,Object? waterEveryDays = null,Object? lastWateredAt = freezed,Object? lastWateredBy = freezed,Object? feedEveryDays = freezed,Object? lastFedAt = freezed,Object? lastFedBy = freezed,Object? note = null,Object? createdBy = null,Object? createdAt = null,Object? history = null,Object? feedHistory = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as Room,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,fileId: freezed == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String?,waterEveryDays: null == waterEveryDays ? _self.waterEveryDays : waterEveryDays // ignore: cast_nullable_to_non_nullable
as int,lastWateredAt: freezed == lastWateredAt ? _self.lastWateredAt : lastWateredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastWateredBy: freezed == lastWateredBy ? _self.lastWateredBy : lastWateredBy // ignore: cast_nullable_to_non_nullable
as String?,feedEveryDays: freezed == feedEveryDays ? _self.feedEveryDays : feedEveryDays // ignore: cast_nullable_to_non_nullable
as int?,lastFedAt: freezed == lastFedAt ? _self.lastFedAt : lastFedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastFedBy: freezed == lastFedBy ? _self.lastFedBy : lastFedBy // ignore: cast_nullable_to_non_nullable
as String?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<WateringEntry>,feedHistory: null == feedHistory ? _self.feedHistory : feedHistory // ignore: cast_nullable_to_non_nullable
as List<WateringEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [Plant].
extension PlantPatterns on Plant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Plant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Plant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Plant value)  $default,){
final _that = this;
switch (_that) {
case _Plant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Plant value)?  $default,){
final _that = this;
switch (_that) {
case _Plant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  Room room,  String? photoPath,  String? fileId,  int waterEveryDays,  DateTime? lastWateredAt,  String? lastWateredBy,  int? feedEveryDays,  DateTime? lastFedAt,  String? lastFedBy,  String note,  String createdBy,  DateTime createdAt,  List<WateringEntry> history,  List<WateringEntry> feedHistory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Plant() when $default != null:
return $default(_that.id,_that.name,_that.room,_that.photoPath,_that.fileId,_that.waterEveryDays,_that.lastWateredAt,_that.lastWateredBy,_that.feedEveryDays,_that.lastFedAt,_that.lastFedBy,_that.note,_that.createdBy,_that.createdAt,_that.history,_that.feedHistory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  Room room,  String? photoPath,  String? fileId,  int waterEveryDays,  DateTime? lastWateredAt,  String? lastWateredBy,  int? feedEveryDays,  DateTime? lastFedAt,  String? lastFedBy,  String note,  String createdBy,  DateTime createdAt,  List<WateringEntry> history,  List<WateringEntry> feedHistory)  $default,) {final _that = this;
switch (_that) {
case _Plant():
return $default(_that.id,_that.name,_that.room,_that.photoPath,_that.fileId,_that.waterEveryDays,_that.lastWateredAt,_that.lastWateredBy,_that.feedEveryDays,_that.lastFedAt,_that.lastFedBy,_that.note,_that.createdBy,_that.createdAt,_that.history,_that.feedHistory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  Room room,  String? photoPath,  String? fileId,  int waterEveryDays,  DateTime? lastWateredAt,  String? lastWateredBy,  int? feedEveryDays,  DateTime? lastFedAt,  String? lastFedBy,  String note,  String createdBy,  DateTime createdAt,  List<WateringEntry> history,  List<WateringEntry> feedHistory)?  $default,) {final _that = this;
switch (_that) {
case _Plant() when $default != null:
return $default(_that.id,_that.name,_that.room,_that.photoPath,_that.fileId,_that.waterEveryDays,_that.lastWateredAt,_that.lastWateredBy,_that.feedEveryDays,_that.lastFedAt,_that.lastFedBy,_that.note,_that.createdBy,_that.createdAt,_that.history,_that.feedHistory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Plant implements Plant {
  const _Plant({required this.id, required this.name, required this.room, this.photoPath, this.fileId, required this.waterEveryDays, this.lastWateredAt, this.lastWateredBy, this.feedEveryDays, this.lastFedAt, this.lastFedBy, this.note = '', required this.createdBy, required this.createdAt, final  List<WateringEntry> history = const <WateringEntry>[], final  List<WateringEntry> feedHistory = const <WateringEntry>[]}): _history = history,_feedHistory = feedHistory;
  factory _Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);

@override final  String id;
@override final  String name;
@override final  Room room;
@override final  String? photoPath;
@override final  String? fileId;
@override final  int waterEveryDays;
@override final  DateTime? lastWateredAt;
@override final  String? lastWateredBy;
@override final  int? feedEveryDays;
@override final  DateTime? lastFedAt;
@override final  String? lastFedBy;
@override@JsonKey() final  String note;
@override final  String createdBy;
@override final  DateTime createdAt;
 final  List<WateringEntry> _history;
@override@JsonKey() List<WateringEntry> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

 final  List<WateringEntry> _feedHistory;
@override@JsonKey() List<WateringEntry> get feedHistory {
  if (_feedHistory is EqualUnmodifiableListView) return _feedHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_feedHistory);
}


/// Create a copy of Plant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlantCopyWith<_Plant> get copyWith => __$PlantCopyWithImpl<_Plant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Plant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.room, room) || other.room == room)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.waterEveryDays, waterEveryDays) || other.waterEveryDays == waterEveryDays)&&(identical(other.lastWateredAt, lastWateredAt) || other.lastWateredAt == lastWateredAt)&&(identical(other.lastWateredBy, lastWateredBy) || other.lastWateredBy == lastWateredBy)&&(identical(other.feedEveryDays, feedEveryDays) || other.feedEveryDays == feedEveryDays)&&(identical(other.lastFedAt, lastFedAt) || other.lastFedAt == lastFedAt)&&(identical(other.lastFedBy, lastFedBy) || other.lastFedBy == lastFedBy)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._history, _history)&&const DeepCollectionEquality().equals(other._feedHistory, _feedHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,room,photoPath,fileId,waterEveryDays,lastWateredAt,lastWateredBy,feedEveryDays,lastFedAt,lastFedBy,note,createdBy,createdAt,const DeepCollectionEquality().hash(_history),const DeepCollectionEquality().hash(_feedHistory));

@override
String toString() {
  return 'Plant(id: $id, name: $name, room: $room, photoPath: $photoPath, fileId: $fileId, waterEveryDays: $waterEveryDays, lastWateredAt: $lastWateredAt, lastWateredBy: $lastWateredBy, feedEveryDays: $feedEveryDays, lastFedAt: $lastFedAt, lastFedBy: $lastFedBy, note: $note, createdBy: $createdBy, createdAt: $createdAt, history: $history, feedHistory: $feedHistory)';
}


}

/// @nodoc
abstract mixin class _$PlantCopyWith<$Res> implements $PlantCopyWith<$Res> {
  factory _$PlantCopyWith(_Plant value, $Res Function(_Plant) _then) = __$PlantCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, Room room, String? photoPath, String? fileId, int waterEveryDays, DateTime? lastWateredAt, String? lastWateredBy, int? feedEveryDays, DateTime? lastFedAt, String? lastFedBy, String note, String createdBy, DateTime createdAt, List<WateringEntry> history, List<WateringEntry> feedHistory
});




}
/// @nodoc
class __$PlantCopyWithImpl<$Res>
    implements _$PlantCopyWith<$Res> {
  __$PlantCopyWithImpl(this._self, this._then);

  final _Plant _self;
  final $Res Function(_Plant) _then;

/// Create a copy of Plant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? room = null,Object? photoPath = freezed,Object? fileId = freezed,Object? waterEveryDays = null,Object? lastWateredAt = freezed,Object? lastWateredBy = freezed,Object? feedEveryDays = freezed,Object? lastFedAt = freezed,Object? lastFedBy = freezed,Object? note = null,Object? createdBy = null,Object? createdAt = null,Object? history = null,Object? feedHistory = null,}) {
  return _then(_Plant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as Room,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,fileId: freezed == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String?,waterEveryDays: null == waterEveryDays ? _self.waterEveryDays : waterEveryDays // ignore: cast_nullable_to_non_nullable
as int,lastWateredAt: freezed == lastWateredAt ? _self.lastWateredAt : lastWateredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastWateredBy: freezed == lastWateredBy ? _self.lastWateredBy : lastWateredBy // ignore: cast_nullable_to_non_nullable
as String?,feedEveryDays: freezed == feedEveryDays ? _self.feedEveryDays : feedEveryDays // ignore: cast_nullable_to_non_nullable
as int?,lastFedAt: freezed == lastFedAt ? _self.lastFedAt : lastFedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastFedBy: freezed == lastFedBy ? _self.lastFedBy : lastFedBy // ignore: cast_nullable_to_non_nullable
as String?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<WateringEntry>,feedHistory: null == feedHistory ? _self._feedHistory : feedHistory // ignore: cast_nullable_to_non_nullable
as List<WateringEntry>,
  ));
}


}


/// @nodoc
mixin _$WateringEntry {

 String get by; DateTime get at;
/// Create a copy of WateringEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WateringEntryCopyWith<WateringEntry> get copyWith => _$WateringEntryCopyWithImpl<WateringEntry>(this as WateringEntry, _$identity);

  /// Serializes this WateringEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WateringEntry&&(identical(other.by, by) || other.by == by)&&(identical(other.at, at) || other.at == at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,by,at);

@override
String toString() {
  return 'WateringEntry(by: $by, at: $at)';
}


}

/// @nodoc
abstract mixin class $WateringEntryCopyWith<$Res>  {
  factory $WateringEntryCopyWith(WateringEntry value, $Res Function(WateringEntry) _then) = _$WateringEntryCopyWithImpl;
@useResult
$Res call({
 String by, DateTime at
});




}
/// @nodoc
class _$WateringEntryCopyWithImpl<$Res>
    implements $WateringEntryCopyWith<$Res> {
  _$WateringEntryCopyWithImpl(this._self, this._then);

  final WateringEntry _self;
  final $Res Function(WateringEntry) _then;

/// Create a copy of WateringEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? by = null,Object? at = null,}) {
  return _then(_self.copyWith(
by: null == by ? _self.by : by // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [WateringEntry].
extension WateringEntryPatterns on WateringEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WateringEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WateringEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WateringEntry value)  $default,){
final _that = this;
switch (_that) {
case _WateringEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WateringEntry value)?  $default,){
final _that = this;
switch (_that) {
case _WateringEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String by,  DateTime at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WateringEntry() when $default != null:
return $default(_that.by,_that.at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String by,  DateTime at)  $default,) {final _that = this;
switch (_that) {
case _WateringEntry():
return $default(_that.by,_that.at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String by,  DateTime at)?  $default,) {final _that = this;
switch (_that) {
case _WateringEntry() when $default != null:
return $default(_that.by,_that.at);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WateringEntry implements WateringEntry {
  const _WateringEntry({required this.by, required this.at});
  factory _WateringEntry.fromJson(Map<String, dynamic> json) => _$WateringEntryFromJson(json);

@override final  String by;
@override final  DateTime at;

/// Create a copy of WateringEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WateringEntryCopyWith<_WateringEntry> get copyWith => __$WateringEntryCopyWithImpl<_WateringEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WateringEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WateringEntry&&(identical(other.by, by) || other.by == by)&&(identical(other.at, at) || other.at == at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,by,at);

@override
String toString() {
  return 'WateringEntry(by: $by, at: $at)';
}


}

/// @nodoc
abstract mixin class _$WateringEntryCopyWith<$Res> implements $WateringEntryCopyWith<$Res> {
  factory _$WateringEntryCopyWith(_WateringEntry value, $Res Function(_WateringEntry) _then) = __$WateringEntryCopyWithImpl;
@override @useResult
$Res call({
 String by, DateTime at
});




}
/// @nodoc
class __$WateringEntryCopyWithImpl<$Res>
    implements _$WateringEntryCopyWith<$Res> {
  __$WateringEntryCopyWithImpl(this._self, this._then);

  final _WateringEntry _self;
  final $Res Function(_WateringEntry) _then;

/// Create a copy of WateringEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? by = null,Object? at = null,}) {
  return _then(_WateringEntry(
by: null == by ? _self.by : by // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
