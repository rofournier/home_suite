// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_tab.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentTab {

 String get id; String get name; List<Document> get documents;
/// Create a copy of DocumentTab
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentTabCopyWith<DocumentTab> get copyWith => _$DocumentTabCopyWithImpl<DocumentTab>(this as DocumentTab, _$identity);

  /// Serializes this DocumentTab to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentTab&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.documents, documents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(documents));

@override
String toString() {
  return 'DocumentTab(id: $id, name: $name, documents: $documents)';
}


}

/// @nodoc
abstract mixin class $DocumentTabCopyWith<$Res>  {
  factory $DocumentTabCopyWith(DocumentTab value, $Res Function(DocumentTab) _then) = _$DocumentTabCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<Document> documents
});




}
/// @nodoc
class _$DocumentTabCopyWithImpl<$Res>
    implements $DocumentTabCopyWith<$Res> {
  _$DocumentTabCopyWithImpl(this._self, this._then);

  final DocumentTab _self;
  final $Res Function(DocumentTab) _then;

/// Create a copy of DocumentTab
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? documents = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<Document>,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentTab].
extension DocumentTabPatterns on DocumentTab {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentTab value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentTab() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentTab value)  $default,){
final _that = this;
switch (_that) {
case _DocumentTab():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentTab value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentTab() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<Document> documents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentTab() when $default != null:
return $default(_that.id,_that.name,_that.documents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<Document> documents)  $default,) {final _that = this;
switch (_that) {
case _DocumentTab():
return $default(_that.id,_that.name,_that.documents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<Document> documents)?  $default,) {final _that = this;
switch (_that) {
case _DocumentTab() when $default != null:
return $default(_that.id,_that.name,_that.documents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentTab extends DocumentTab {
  const _DocumentTab({required this.id, required this.name, final  List<Document> documents = const <Document>[]}): _documents = documents,super._();
  factory _DocumentTab.fromJson(Map<String, dynamic> json) => _$DocumentTabFromJson(json);

@override final  String id;
@override final  String name;
 final  List<Document> _documents;
@override@JsonKey() List<Document> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}


/// Create a copy of DocumentTab
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentTabCopyWith<_DocumentTab> get copyWith => __$DocumentTabCopyWithImpl<_DocumentTab>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentTabToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentTab&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._documents, _documents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_documents));

@override
String toString() {
  return 'DocumentTab(id: $id, name: $name, documents: $documents)';
}


}

/// @nodoc
abstract mixin class _$DocumentTabCopyWith<$Res> implements $DocumentTabCopyWith<$Res> {
  factory _$DocumentTabCopyWith(_DocumentTab value, $Res Function(_DocumentTab) _then) = __$DocumentTabCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<Document> documents
});




}
/// @nodoc
class __$DocumentTabCopyWithImpl<$Res>
    implements _$DocumentTabCopyWith<$Res> {
  __$DocumentTabCopyWithImpl(this._self, this._then);

  final _DocumentTab _self;
  final $Res Function(_DocumentTab) _then;

/// Create a copy of DocumentTab
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? documents = null,}) {
  return _then(_DocumentTab(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<Document>,
  ));
}


}

// dart format on
