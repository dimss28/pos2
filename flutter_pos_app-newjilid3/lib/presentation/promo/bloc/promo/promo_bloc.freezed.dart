// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'promo_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PromoEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is PromoEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PromoEvent()';
  }
}

/// @nodoc
class $PromoEventCopyWith<$Res> {
  $PromoEventCopyWith(PromoEvent _, $Res Function(PromoEvent) __);
}

/// Adds pattern-matching-related methods to [PromoEvent].
extension PromoEventPatterns on PromoEvent {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LoadFromCache value)? loadFromCache,
    TResult Function(_RefreshFromRemote value)? refreshFromRemote,
    TResult Function(_Toggle value)? toggle,
    TResult Function(_Save value)? save,
    TResult Function(_Delete value)? delete,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LoadFromCache() when loadFromCache != null:
        return loadFromCache(_that);
      case _RefreshFromRemote() when refreshFromRemote != null:
        return refreshFromRemote(_that);
      case _Toggle() when toggle != null:
        return toggle(_that);
      case _Save() when save != null:
        return save(_that);
      case _Delete() when delete != null:
        return delete(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LoadFromCache value) loadFromCache,
    required TResult Function(_RefreshFromRemote value) refreshFromRemote,
    required TResult Function(_Toggle value) toggle,
    required TResult Function(_Save value) save,
    required TResult Function(_Delete value) delete,
  }) {
    final _that = this;
    switch (_that) {
      case _LoadFromCache():
        return loadFromCache(_that);
      case _RefreshFromRemote():
        return refreshFromRemote(_that);
      case _Toggle():
        return toggle(_that);
      case _Save():
        return save(_that);
      case _Delete():
        return delete(_that);
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LoadFromCache value)? loadFromCache,
    TResult? Function(_RefreshFromRemote value)? refreshFromRemote,
    TResult? Function(_Toggle value)? toggle,
    TResult? Function(_Save value)? save,
    TResult? Function(_Delete value)? delete,
  }) {
    final _that = this;
    switch (_that) {
      case _LoadFromCache() when loadFromCache != null:
        return loadFromCache(_that);
      case _RefreshFromRemote() when refreshFromRemote != null:
        return refreshFromRemote(_that);
      case _Toggle() when toggle != null:
        return toggle(_that);
      case _Save() when save != null:
        return save(_that);
      case _Delete() when delete != null:
        return delete(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadFromCache,
    TResult Function()? refreshFromRemote,
    TResult Function(int id)? toggle,
    TResult Function(PromoModel promo)? save,
    TResult Function(int id)? delete,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LoadFromCache() when loadFromCache != null:
        return loadFromCache();
      case _RefreshFromRemote() when refreshFromRemote != null:
        return refreshFromRemote();
      case _Toggle() when toggle != null:
        return toggle(_that.id);
      case _Save() when save != null:
        return save(_that.promo);
      case _Delete() when delete != null:
        return delete(_that.id);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadFromCache,
    required TResult Function() refreshFromRemote,
    required TResult Function(int id) toggle,
    required TResult Function(PromoModel promo) save,
    required TResult Function(int id) delete,
  }) {
    final _that = this;
    switch (_that) {
      case _LoadFromCache():
        return loadFromCache();
      case _RefreshFromRemote():
        return refreshFromRemote();
      case _Toggle():
        return toggle(_that.id);
      case _Save():
        return save(_that.promo);
      case _Delete():
        return delete(_that.id);
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadFromCache,
    TResult? Function()? refreshFromRemote,
    TResult? Function(int id)? toggle,
    TResult? Function(PromoModel promo)? save,
    TResult? Function(int id)? delete,
  }) {
    final _that = this;
    switch (_that) {
      case _LoadFromCache() when loadFromCache != null:
        return loadFromCache();
      case _RefreshFromRemote() when refreshFromRemote != null:
        return refreshFromRemote();
      case _Toggle() when toggle != null:
        return toggle(_that.id);
      case _Save() when save != null:
        return save(_that.promo);
      case _Delete() when delete != null:
        return delete(_that.id);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LoadFromCache implements PromoEvent {
  const _LoadFromCache();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _LoadFromCache);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PromoEvent.loadFromCache()';
  }
}

/// @nodoc

class _RefreshFromRemote implements PromoEvent {
  const _RefreshFromRemote();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _RefreshFromRemote);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PromoEvent.refreshFromRemote()';
  }
}

/// @nodoc

class _Toggle implements PromoEvent {
  const _Toggle(this.id);

  final int id;

  /// Create a copy of PromoEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ToggleCopyWith<_Toggle> get copyWith =>
      __$ToggleCopyWithImpl<_Toggle>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Toggle &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'PromoEvent.toggle(id: $id)';
  }
}

/// @nodoc
abstract mixin class _$ToggleCopyWith<$Res>
    implements $PromoEventCopyWith<$Res> {
  factory _$ToggleCopyWith(_Toggle value, $Res Function(_Toggle) _then) =
      __$ToggleCopyWithImpl;
  @useResult
  $Res call({int id});
}

/// @nodoc
class __$ToggleCopyWithImpl<$Res> implements _$ToggleCopyWith<$Res> {
  __$ToggleCopyWithImpl(this._self, this._then);

  final _Toggle _self;
  final $Res Function(_Toggle) _then;

  /// Create a copy of PromoEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(_Toggle(
      null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _Save implements PromoEvent {
  const _Save(this.promo);

  final PromoModel promo;

  /// Create a copy of PromoEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SaveCopyWith<_Save> get copyWith =>
      __$SaveCopyWithImpl<_Save>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Save &&
            (identical(other.promo, promo) || other.promo == promo));
  }

  @override
  int get hashCode => Object.hash(runtimeType, promo);

  @override
  String toString() {
    return 'PromoEvent.save(promo: $promo)';
  }
}

/// @nodoc
abstract mixin class _$SaveCopyWith<$Res> implements $PromoEventCopyWith<$Res> {
  factory _$SaveCopyWith(_Save value, $Res Function(_Save) _then) =
      __$SaveCopyWithImpl;
  @useResult
  $Res call({PromoModel promo});
}

/// @nodoc
class __$SaveCopyWithImpl<$Res> implements _$SaveCopyWith<$Res> {
  __$SaveCopyWithImpl(this._self, this._then);

  final _Save _self;
  final $Res Function(_Save) _then;

  /// Create a copy of PromoEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? promo = null,
  }) {
    return _then(_Save(
      null == promo
          ? _self.promo
          : promo // ignore: cast_nullable_to_non_nullable
              as PromoModel,
    ));
  }
}

/// @nodoc

class _Delete implements PromoEvent {
  const _Delete(this.id);

  final int id;

  /// Create a copy of PromoEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeleteCopyWith<_Delete> get copyWith =>
      __$DeleteCopyWithImpl<_Delete>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Delete &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'PromoEvent.delete(id: $id)';
  }
}

/// @nodoc
abstract mixin class _$DeleteCopyWith<$Res>
    implements $PromoEventCopyWith<$Res> {
  factory _$DeleteCopyWith(_Delete value, $Res Function(_Delete) _then) =
      __$DeleteCopyWithImpl;
  @useResult
  $Res call({int id});
}

/// @nodoc
class __$DeleteCopyWithImpl<$Res> implements _$DeleteCopyWith<$Res> {
  __$DeleteCopyWithImpl(this._self, this._then);

  final _Delete _self;
  final $Res Function(_Delete) _then;

  /// Create a copy of PromoEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(_Delete(
      null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$PromoState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is PromoState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PromoState()';
  }
}

/// @nodoc
class $PromoStateCopyWith<$Res> {
  $PromoStateCopyWith(PromoState _, $Res Function(PromoState) __);
}

/// Adds pattern-matching-related methods to [PromoState].
extension PromoStatePatterns on PromoState {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case _Loading() when loading != null:
        return loading(_that);
      case _Success() when success != null:
        return success(_that);
      case _Error() when error != null:
        return error(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial(_that);
      case _Loading():
        return loading(_that);
      case _Success():
        return success(_that);
      case _Error():
        return error(_that);
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case _Loading() when loading != null:
        return loading(_that);
      case _Success() when success != null:
        return success(_that);
      case _Error() when error != null:
        return error(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<PromoModel> promos)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Loading() when loading != null:
        return loading();
      case _Success() when success != null:
        return success(_that.promos);
      case _Error() when error != null:
        return error(_that.message);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<PromoModel> promos) success,
    required TResult Function(String message) error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial();
      case _Loading():
        return loading();
      case _Success():
        return success(_that.promos);
      case _Error():
        return error(_that.message);
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<PromoModel> promos)? success,
    TResult? Function(String message)? error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Loading() when loading != null:
        return loading();
      case _Success() when success != null:
        return success(_that.promos);
      case _Error() when error != null:
        return error(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Initial implements PromoState {
  const _Initial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Initial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PromoState.initial()';
  }
}

/// @nodoc

class _Loading implements PromoState {
  const _Loading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Loading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PromoState.loading()';
  }
}

/// @nodoc

class _Success implements PromoState {
  const _Success(final List<PromoModel> promos) : _promos = promos;

  final List<PromoModel> _promos;
  List<PromoModel> get promos {
    if (_promos is EqualUnmodifiableListView) return _promos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_promos);
  }

  /// Create a copy of PromoState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SuccessCopyWith<_Success> get copyWith =>
      __$SuccessCopyWithImpl<_Success>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Success &&
            const DeepCollectionEquality().equals(other._promos, _promos));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_promos));

  @override
  String toString() {
    return 'PromoState.success(promos: $promos)';
  }
}

/// @nodoc
abstract mixin class _$SuccessCopyWith<$Res>
    implements $PromoStateCopyWith<$Res> {
  factory _$SuccessCopyWith(_Success value, $Res Function(_Success) _then) =
      __$SuccessCopyWithImpl;
  @useResult
  $Res call({List<PromoModel> promos});
}

/// @nodoc
class __$SuccessCopyWithImpl<$Res> implements _$SuccessCopyWith<$Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success _self;
  final $Res Function(_Success) _then;

  /// Create a copy of PromoState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? promos = null,
  }) {
    return _then(_Success(
      null == promos
          ? _self._promos
          : promos // ignore: cast_nullable_to_non_nullable
              as List<PromoModel>,
    ));
  }
}

/// @nodoc

class _Error implements PromoState {
  const _Error(this.message);

  final String message;

  /// Create a copy of PromoState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ErrorCopyWith<_Error> get copyWith =>
      __$ErrorCopyWithImpl<_Error>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Error &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'PromoState.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res>
    implements $PromoStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) =
      __$ErrorCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$ErrorCopyWithImpl<$Res> implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

  /// Create a copy of PromoState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(_Error(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
