// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cash_session_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CashSessionEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CashSessionEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CashSessionEvent()';
  }
}

/// @nodoc
class $CashSessionEventCopyWith<$Res> {
  $CashSessionEventCopyWith(
      CashSessionEvent _, $Res Function(CashSessionEvent) __);
}

/// Adds pattern-matching-related methods to [CashSessionEvent].
extension CashSessionEventPatterns on CashSessionEvent {
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
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Open value)? open,
    TResult Function(_Close value)? close,
    TResult Function(_Reset value)? reset,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Loaded() when loaded != null:
        return loaded(_that);
      case _Open() when open != null:
        return open(_that);
      case _Close() when close != null:
        return close(_that);
      case _Reset() when reset != null:
        return reset(_that);
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
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Open value) open,
    required TResult Function(_Close value) close,
    required TResult Function(_Reset value) reset,
  }) {
    final _that = this;
    switch (_that) {
      case _Loaded():
        return loaded(_that);
      case _Open():
        return open(_that);
      case _Close():
        return close(_that);
      case _Reset():
        return reset(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Open value)? open,
    TResult? Function(_Close value)? close,
    TResult? Function(_Reset value)? reset,
  }) {
    final _that = this;
    switch (_that) {
      case _Loaded() when loaded != null:
        return loaded(_that);
      case _Open() when open != null:
        return open(_that);
      case _Close() when close != null:
        return close(_that);
      case _Reset() when reset != null:
        return reset(_that);
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
    TResult Function()? loaded,
    TResult Function(String shiftLabel, int openingFloat, String? note)? open,
    TResult Function(
            int physicalCount, int? cashIn, int? cashOut, String? note)?
        close,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Loaded() when loaded != null:
        return loaded();
      case _Open() when open != null:
        return open(_that.shiftLabel, _that.openingFloat, _that.note);
      case _Close() when close != null:
        return close(
            _that.physicalCount, _that.cashIn, _that.cashOut, _that.note);
      case _Reset() when reset != null:
        return reset();
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
    required TResult Function() loaded,
    required TResult Function(String shiftLabel, int openingFloat, String? note)
        open,
    required TResult Function(
            int physicalCount, int? cashIn, int? cashOut, String? note)
        close,
    required TResult Function() reset,
  }) {
    final _that = this;
    switch (_that) {
      case _Loaded():
        return loaded();
      case _Open():
        return open(_that.shiftLabel, _that.openingFloat, _that.note);
      case _Close():
        return close(
            _that.physicalCount, _that.cashIn, _that.cashOut, _that.note);
      case _Reset():
        return reset();
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loaded,
    TResult? Function(String shiftLabel, int openingFloat, String? note)? open,
    TResult? Function(
            int physicalCount, int? cashIn, int? cashOut, String? note)?
        close,
    TResult? Function()? reset,
  }) {
    final _that = this;
    switch (_that) {
      case _Loaded() when loaded != null:
        return loaded();
      case _Open() when open != null:
        return open(_that.shiftLabel, _that.openingFloat, _that.note);
      case _Close() when close != null:
        return close(
            _that.physicalCount, _that.cashIn, _that.cashOut, _that.note);
      case _Reset() when reset != null:
        return reset();
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Loaded implements CashSessionEvent {
  const _Loaded();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Loaded);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CashSessionEvent.loaded()';
  }
}

/// @nodoc

class _Open implements CashSessionEvent {
  const _Open(
      {required this.shiftLabel, required this.openingFloat, this.note});

  final String shiftLabel;
  final int openingFloat;
  final String? note;

  /// Create a copy of CashSessionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OpenCopyWith<_Open> get copyWith =>
      __$OpenCopyWithImpl<_Open>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Open &&
            (identical(other.shiftLabel, shiftLabel) ||
                other.shiftLabel == shiftLabel) &&
            (identical(other.openingFloat, openingFloat) ||
                other.openingFloat == openingFloat) &&
            (identical(other.note, note) || other.note == note));
  }

  @override
  int get hashCode => Object.hash(runtimeType, shiftLabel, openingFloat, note);

  @override
  String toString() {
    return 'CashSessionEvent.open(shiftLabel: $shiftLabel, openingFloat: $openingFloat, note: $note)';
  }
}

/// @nodoc
abstract mixin class _$OpenCopyWith<$Res>
    implements $CashSessionEventCopyWith<$Res> {
  factory _$OpenCopyWith(_Open value, $Res Function(_Open) _then) =
      __$OpenCopyWithImpl;
  @useResult
  $Res call({String shiftLabel, int openingFloat, String? note});
}

/// @nodoc
class __$OpenCopyWithImpl<$Res> implements _$OpenCopyWith<$Res> {
  __$OpenCopyWithImpl(this._self, this._then);

  final _Open _self;
  final $Res Function(_Open) _then;

  /// Create a copy of CashSessionEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? shiftLabel = null,
    Object? openingFloat = null,
    Object? note = freezed,
  }) {
    return _then(_Open(
      shiftLabel: null == shiftLabel
          ? _self.shiftLabel
          : shiftLabel // ignore: cast_nullable_to_non_nullable
              as String,
      openingFloat: null == openingFloat
          ? _self.openingFloat
          : openingFloat // ignore: cast_nullable_to_non_nullable
              as int,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _Close implements CashSessionEvent {
  const _Close(
      {required this.physicalCount, this.cashIn, this.cashOut, this.note});

  final int physicalCount;
  final int? cashIn;
  final int? cashOut;
  final String? note;

  /// Create a copy of CashSessionEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CloseCopyWith<_Close> get copyWith =>
      __$CloseCopyWithImpl<_Close>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Close &&
            (identical(other.physicalCount, physicalCount) ||
                other.physicalCount == physicalCount) &&
            (identical(other.cashIn, cashIn) || other.cashIn == cashIn) &&
            (identical(other.cashOut, cashOut) || other.cashOut == cashOut) &&
            (identical(other.note, note) || other.note == note));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, physicalCount, cashIn, cashOut, note);

  @override
  String toString() {
    return 'CashSessionEvent.close(physicalCount: $physicalCount, cashIn: $cashIn, cashOut: $cashOut, note: $note)';
  }
}

/// @nodoc
abstract mixin class _$CloseCopyWith<$Res>
    implements $CashSessionEventCopyWith<$Res> {
  factory _$CloseCopyWith(_Close value, $Res Function(_Close) _then) =
      __$CloseCopyWithImpl;
  @useResult
  $Res call({int physicalCount, int? cashIn, int? cashOut, String? note});
}

/// @nodoc
class __$CloseCopyWithImpl<$Res> implements _$CloseCopyWith<$Res> {
  __$CloseCopyWithImpl(this._self, this._then);

  final _Close _self;
  final $Res Function(_Close) _then;

  /// Create a copy of CashSessionEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? physicalCount = null,
    Object? cashIn = freezed,
    Object? cashOut = freezed,
    Object? note = freezed,
  }) {
    return _then(_Close(
      physicalCount: null == physicalCount
          ? _self.physicalCount
          : physicalCount // ignore: cast_nullable_to_non_nullable
              as int,
      cashIn: freezed == cashIn
          ? _self.cashIn
          : cashIn // ignore: cast_nullable_to_non_nullable
              as int?,
      cashOut: freezed == cashOut
          ? _self.cashOut
          : cashOut // ignore: cast_nullable_to_non_nullable
              as int?,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _Reset implements CashSessionEvent {
  const _Reset();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Reset);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CashSessionEvent.reset()';
  }
}

/// @nodoc
mixin _$CashSessionState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CashSessionState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CashSessionState()';
  }
}

/// @nodoc
class $CashSessionStateCopyWith<$Res> {
  $CashSessionStateCopyWith(
      CashSessionState _, $Res Function(CashSessionState) __);
}

/// Adds pattern-matching-related methods to [CashSessionState].
extension CashSessionStatePatterns on CashSessionState {
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
    TResult Function(_NoSession value)? noSession,
    TResult Function(_Active value)? open,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case _Loading() when loading != null:
        return loading(_that);
      case _NoSession() when noSession != null:
        return noSession(_that);
      case _Active() when open != null:
        return open(_that);
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
    required TResult Function(_NoSession value) noSession,
    required TResult Function(_Active value) open,
    required TResult Function(_Error value) error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial(_that);
      case _Loading():
        return loading(_that);
      case _NoSession():
        return noSession(_that);
      case _Active():
        return open(_that);
      case _Error():
        return error(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_NoSession value)? noSession,
    TResult? Function(_Active value)? open,
    TResult? Function(_Error value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case _Loading() when loading != null:
        return loading(_that);
      case _NoSession() when noSession != null:
        return noSession(_that);
      case _Active() when open != null:
        return open(_that);
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
    TResult Function(CashSessionModel? lastClosed)? noSession,
    TResult Function(CashSessionModel current)? open,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Loading() when loading != null:
        return loading();
      case _NoSession() when noSession != null:
        return noSession(_that.lastClosed);
      case _Active() when open != null:
        return open(_that.current);
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
    required TResult Function(CashSessionModel? lastClosed) noSession,
    required TResult Function(CashSessionModel current) open,
    required TResult Function(String message) error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial();
      case _Loading():
        return loading();
      case _NoSession():
        return noSession(_that.lastClosed);
      case _Active():
        return open(_that.current);
      case _Error():
        return error(_that.message);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(CashSessionModel? lastClosed)? noSession,
    TResult? Function(CashSessionModel current)? open,
    TResult? Function(String message)? error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Loading() when loading != null:
        return loading();
      case _NoSession() when noSession != null:
        return noSession(_that.lastClosed);
      case _Active() when open != null:
        return open(_that.current);
      case _Error() when error != null:
        return error(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Initial implements CashSessionState {
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
    return 'CashSessionState.initial()';
  }
}

/// @nodoc

class _Loading implements CashSessionState {
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
    return 'CashSessionState.loading()';
  }
}

/// @nodoc

class _NoSession implements CashSessionState {
  const _NoSession([this.lastClosed]);

  final CashSessionModel? lastClosed;

  /// Create a copy of CashSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NoSessionCopyWith<_NoSession> get copyWith =>
      __$NoSessionCopyWithImpl<_NoSession>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NoSession &&
            (identical(other.lastClosed, lastClosed) ||
                other.lastClosed == lastClosed));
  }

  @override
  int get hashCode => Object.hash(runtimeType, lastClosed);

  @override
  String toString() {
    return 'CashSessionState.noSession(lastClosed: $lastClosed)';
  }
}

/// @nodoc
abstract mixin class _$NoSessionCopyWith<$Res>
    implements $CashSessionStateCopyWith<$Res> {
  factory _$NoSessionCopyWith(
          _NoSession value, $Res Function(_NoSession) _then) =
      __$NoSessionCopyWithImpl;
  @useResult
  $Res call({CashSessionModel? lastClosed});
}

/// @nodoc
class __$NoSessionCopyWithImpl<$Res> implements _$NoSessionCopyWith<$Res> {
  __$NoSessionCopyWithImpl(this._self, this._then);

  final _NoSession _self;
  final $Res Function(_NoSession) _then;

  /// Create a copy of CashSessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? lastClosed = freezed,
  }) {
    return _then(_NoSession(
      freezed == lastClosed
          ? _self.lastClosed
          : lastClosed // ignore: cast_nullable_to_non_nullable
              as CashSessionModel?,
    ));
  }
}

/// @nodoc

class _Active implements CashSessionState {
  const _Active(this.current);

  final CashSessionModel current;

  /// Create a copy of CashSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ActiveCopyWith<_Active> get copyWith =>
      __$ActiveCopyWithImpl<_Active>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Active &&
            (identical(other.current, current) || other.current == current));
  }

  @override
  int get hashCode => Object.hash(runtimeType, current);

  @override
  String toString() {
    return 'CashSessionState.open(current: $current)';
  }
}

/// @nodoc
abstract mixin class _$ActiveCopyWith<$Res>
    implements $CashSessionStateCopyWith<$Res> {
  factory _$ActiveCopyWith(_Active value, $Res Function(_Active) _then) =
      __$ActiveCopyWithImpl;
  @useResult
  $Res call({CashSessionModel current});
}

/// @nodoc
class __$ActiveCopyWithImpl<$Res> implements _$ActiveCopyWith<$Res> {
  __$ActiveCopyWithImpl(this._self, this._then);

  final _Active _self;
  final $Res Function(_Active) _then;

  /// Create a copy of CashSessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? current = null,
  }) {
    return _then(_Active(
      null == current
          ? _self.current
          : current // ignore: cast_nullable_to_non_nullable
              as CashSessionModel,
    ));
  }
}

/// @nodoc

class _Error implements CashSessionState {
  const _Error(this.message);

  final String message;

  /// Create a copy of CashSessionState
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
    return 'CashSessionState.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res>
    implements $CashSessionStateCopyWith<$Res> {
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

  /// Create a copy of CashSessionState
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
