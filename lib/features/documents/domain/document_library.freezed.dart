// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_library.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentLibrary {

 String get householdId; List<DocumentTab> get tabs; DateTime? get updatedAt;
/// Create a copy of DocumentLibrary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentLibraryCopyWith<DocumentLibrary> get copyWith => _$DocumentLibraryCopyWithImpl<DocumentLibrary>(this as DocumentLibrary, _$identity);

  /// Serializes this DocumentLibrary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentLibrary&&(identical(other.householdId, householdId) || other.householdId == householdId)&&const DeepCollectionEquality().equals(other.tabs, tabs)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,householdId,const DeepCollectionEquality().hash(tabs),updatedAt);

@override
String toString() {
  return 'DocumentLibrary(householdId: $householdId, tabs: $tabs, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DocumentLibraryCopyWith<$Res>  {
  factory $DocumentLibraryCopyWith(DocumentLibrary value, $Res Function(DocumentLibrary) _then) = _$DocumentLibraryCopyWithImpl;
@useResult
$Res call({
 String householdId, List<DocumentTab> tabs, DateTime? updatedAt
});




}
/// @nodoc
class _$DocumentLibraryCopyWithImpl<$Res>
    implements $DocumentLibraryCopyWith<$Res> {
  _$DocumentLibraryCopyWithImpl(this._self, this._then);

  final DocumentLibrary _self;
  final $Res Function(DocumentLibrary) _then;

/// Create a copy of DocumentLibrary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? householdId = null,Object? tabs = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,tabs: null == tabs ? _self.tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<DocumentTab>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentLibrary].
extension DocumentLibraryPatterns on DocumentLibrary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentLibrary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentLibrary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentLibrary value)  $default,){
final _that = this;
switch (_that) {
case _DocumentLibrary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentLibrary value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentLibrary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String householdId,  List<DocumentTab> tabs,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentLibrary() when $default != null:
return $default(_that.householdId,_that.tabs,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String householdId,  List<DocumentTab> tabs,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DocumentLibrary():
return $default(_that.householdId,_that.tabs,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String householdId,  List<DocumentTab> tabs,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DocumentLibrary() when $default != null:
return $default(_that.householdId,_that.tabs,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentLibrary extends DocumentLibrary {
  const _DocumentLibrary({required this.householdId, final  List<DocumentTab> tabs = const <DocumentTab>[], this.updatedAt}): _tabs = tabs,super._();
  factory _DocumentLibrary.fromJson(Map<String, dynamic> json) => _$DocumentLibraryFromJson(json);

@override final  String householdId;
 final  List<DocumentTab> _tabs;
@override@JsonKey() List<DocumentTab> get tabs {
  if (_tabs is EqualUnmodifiableListView) return _tabs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tabs);
}

@override final  DateTime? updatedAt;

/// Create a copy of DocumentLibrary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentLibraryCopyWith<_DocumentLibrary> get copyWith => __$DocumentLibraryCopyWithImpl<_DocumentLibrary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentLibraryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentLibrary&&(identical(other.householdId, householdId) || other.householdId == householdId)&&const DeepCollectionEquality().equals(other._tabs, _tabs)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,householdId,const DeepCollectionEquality().hash(_tabs),updatedAt);

@override
String toString() {
  return 'DocumentLibrary(householdId: $householdId, tabs: $tabs, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DocumentLibraryCopyWith<$Res> implements $DocumentLibraryCopyWith<$Res> {
  factory _$DocumentLibraryCopyWith(_DocumentLibrary value, $Res Function(_DocumentLibrary) _then) = __$DocumentLibraryCopyWithImpl;
@override @useResult
$Res call({
 String householdId, List<DocumentTab> tabs, DateTime? updatedAt
});




}
/// @nodoc
class __$DocumentLibraryCopyWithImpl<$Res>
    implements _$DocumentLibraryCopyWith<$Res> {
  __$DocumentLibraryCopyWithImpl(this._self, this._then);

  final _DocumentLibrary _self;
  final $Res Function(_DocumentLibrary) _then;

/// Create a copy of DocumentLibrary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? householdId = null,Object? tabs = null,Object? updatedAt = freezed,}) {
  return _then(_DocumentLibrary(
householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,tabs: null == tabs ? _self._tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<DocumentTab>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
