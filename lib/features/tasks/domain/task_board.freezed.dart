// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_board.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemberScore {

 String get memberId; int get points; int get completedCount; int get createdCount;
/// Create a copy of MemberScore
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberScoreCopyWith<MemberScore> get copyWith => _$MemberScoreCopyWithImpl<MemberScore>(this as MemberScore, _$identity);

  /// Serializes this MemberScore to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberScore&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.points, points) || other.points == points)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.createdCount, createdCount) || other.createdCount == createdCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,points,completedCount,createdCount);

@override
String toString() {
  return 'MemberScore(memberId: $memberId, points: $points, completedCount: $completedCount, createdCount: $createdCount)';
}


}

/// @nodoc
abstract mixin class $MemberScoreCopyWith<$Res>  {
  factory $MemberScoreCopyWith(MemberScore value, $Res Function(MemberScore) _then) = _$MemberScoreCopyWithImpl;
@useResult
$Res call({
 String memberId, int points, int completedCount, int createdCount
});




}
/// @nodoc
class _$MemberScoreCopyWithImpl<$Res>
    implements $MemberScoreCopyWith<$Res> {
  _$MemberScoreCopyWithImpl(this._self, this._then);

  final MemberScore _self;
  final $Res Function(MemberScore) _then;

/// Create a copy of MemberScore
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memberId = null,Object? points = null,Object? completedCount = null,Object? createdCount = null,}) {
  return _then(_self.copyWith(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,createdCount: null == createdCount ? _self.createdCount : createdCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberScore].
extension MemberScorePatterns on MemberScore {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberScore value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberScore() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberScore value)  $default,){
final _that = this;
switch (_that) {
case _MemberScore():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberScore value)?  $default,){
final _that = this;
switch (_that) {
case _MemberScore() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String memberId,  int points,  int completedCount,  int createdCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberScore() when $default != null:
return $default(_that.memberId,_that.points,_that.completedCount,_that.createdCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String memberId,  int points,  int completedCount,  int createdCount)  $default,) {final _that = this;
switch (_that) {
case _MemberScore():
return $default(_that.memberId,_that.points,_that.completedCount,_that.createdCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String memberId,  int points,  int completedCount,  int createdCount)?  $default,) {final _that = this;
switch (_that) {
case _MemberScore() when $default != null:
return $default(_that.memberId,_that.points,_that.completedCount,_that.createdCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberScore implements MemberScore {
  const _MemberScore({required this.memberId, this.points = 0, this.completedCount = 0, this.createdCount = 0});
  factory _MemberScore.fromJson(Map<String, dynamic> json) => _$MemberScoreFromJson(json);

@override final  String memberId;
@override@JsonKey() final  int points;
@override@JsonKey() final  int completedCount;
@override@JsonKey() final  int createdCount;

/// Create a copy of MemberScore
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberScoreCopyWith<_MemberScore> get copyWith => __$MemberScoreCopyWithImpl<_MemberScore>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberScoreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberScore&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.points, points) || other.points == points)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.createdCount, createdCount) || other.createdCount == createdCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,points,completedCount,createdCount);

@override
String toString() {
  return 'MemberScore(memberId: $memberId, points: $points, completedCount: $completedCount, createdCount: $createdCount)';
}


}

/// @nodoc
abstract mixin class _$MemberScoreCopyWith<$Res> implements $MemberScoreCopyWith<$Res> {
  factory _$MemberScoreCopyWith(_MemberScore value, $Res Function(_MemberScore) _then) = __$MemberScoreCopyWithImpl;
@override @useResult
$Res call({
 String memberId, int points, int completedCount, int createdCount
});




}
/// @nodoc
class __$MemberScoreCopyWithImpl<$Res>
    implements _$MemberScoreCopyWith<$Res> {
  __$MemberScoreCopyWithImpl(this._self, this._then);

  final _MemberScore _self;
  final $Res Function(_MemberScore) _then;

/// Create a copy of MemberScore
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memberId = null,Object? points = null,Object? completedCount = null,Object? createdCount = null,}) {
  return _then(_MemberScore(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,createdCount: null == createdCount ? _self.createdCount : createdCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TaskBoard {

 String get householdId; List<HouseTask> get tasks; List<MemberScore> get scores; DateTime? get updatedAt;
/// Create a copy of TaskBoard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskBoardCopyWith<TaskBoard> get copyWith => _$TaskBoardCopyWithImpl<TaskBoard>(this as TaskBoard, _$identity);

  /// Serializes this TaskBoard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskBoard&&(identical(other.householdId, householdId) || other.householdId == householdId)&&const DeepCollectionEquality().equals(other.tasks, tasks)&&const DeepCollectionEquality().equals(other.scores, scores)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,householdId,const DeepCollectionEquality().hash(tasks),const DeepCollectionEquality().hash(scores),updatedAt);

@override
String toString() {
  return 'TaskBoard(householdId: $householdId, tasks: $tasks, scores: $scores, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TaskBoardCopyWith<$Res>  {
  factory $TaskBoardCopyWith(TaskBoard value, $Res Function(TaskBoard) _then) = _$TaskBoardCopyWithImpl;
@useResult
$Res call({
 String householdId, List<HouseTask> tasks, List<MemberScore> scores, DateTime? updatedAt
});




}
/// @nodoc
class _$TaskBoardCopyWithImpl<$Res>
    implements $TaskBoardCopyWith<$Res> {
  _$TaskBoardCopyWithImpl(this._self, this._then);

  final TaskBoard _self;
  final $Res Function(TaskBoard) _then;

/// Create a copy of TaskBoard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? householdId = null,Object? tasks = null,Object? scores = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<HouseTask>,scores: null == scores ? _self.scores : scores // ignore: cast_nullable_to_non_nullable
as List<MemberScore>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskBoard].
extension TaskBoardPatterns on TaskBoard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskBoard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskBoard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskBoard value)  $default,){
final _that = this;
switch (_that) {
case _TaskBoard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskBoard value)?  $default,){
final _that = this;
switch (_that) {
case _TaskBoard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String householdId,  List<HouseTask> tasks,  List<MemberScore> scores,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskBoard() when $default != null:
return $default(_that.householdId,_that.tasks,_that.scores,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String householdId,  List<HouseTask> tasks,  List<MemberScore> scores,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TaskBoard():
return $default(_that.householdId,_that.tasks,_that.scores,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String householdId,  List<HouseTask> tasks,  List<MemberScore> scores,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TaskBoard() when $default != null:
return $default(_that.householdId,_that.tasks,_that.scores,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskBoard extends TaskBoard {
  const _TaskBoard({required this.householdId, final  List<HouseTask> tasks = const <HouseTask>[], final  List<MemberScore> scores = const <MemberScore>[], this.updatedAt}): _tasks = tasks,_scores = scores,super._();
  factory _TaskBoard.fromJson(Map<String, dynamic> json) => _$TaskBoardFromJson(json);

@override final  String householdId;
 final  List<HouseTask> _tasks;
@override@JsonKey() List<HouseTask> get tasks {
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tasks);
}

 final  List<MemberScore> _scores;
@override@JsonKey() List<MemberScore> get scores {
  if (_scores is EqualUnmodifiableListView) return _scores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scores);
}

@override final  DateTime? updatedAt;

/// Create a copy of TaskBoard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskBoardCopyWith<_TaskBoard> get copyWith => __$TaskBoardCopyWithImpl<_TaskBoard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskBoardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskBoard&&(identical(other.householdId, householdId) || other.householdId == householdId)&&const DeepCollectionEquality().equals(other._tasks, _tasks)&&const DeepCollectionEquality().equals(other._scores, _scores)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,householdId,const DeepCollectionEquality().hash(_tasks),const DeepCollectionEquality().hash(_scores),updatedAt);

@override
String toString() {
  return 'TaskBoard(householdId: $householdId, tasks: $tasks, scores: $scores, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TaskBoardCopyWith<$Res> implements $TaskBoardCopyWith<$Res> {
  factory _$TaskBoardCopyWith(_TaskBoard value, $Res Function(_TaskBoard) _then) = __$TaskBoardCopyWithImpl;
@override @useResult
$Res call({
 String householdId, List<HouseTask> tasks, List<MemberScore> scores, DateTime? updatedAt
});




}
/// @nodoc
class __$TaskBoardCopyWithImpl<$Res>
    implements _$TaskBoardCopyWith<$Res> {
  __$TaskBoardCopyWithImpl(this._self, this._then);

  final _TaskBoard _self;
  final $Res Function(_TaskBoard) _then;

/// Create a copy of TaskBoard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? householdId = null,Object? tasks = null,Object? scores = null,Object? updatedAt = freezed,}) {
  return _then(_TaskBoard(
householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<HouseTask>,scores: null == scores ? _self._scores : scores // ignore: cast_nullable_to_non_nullable
as List<MemberScore>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
