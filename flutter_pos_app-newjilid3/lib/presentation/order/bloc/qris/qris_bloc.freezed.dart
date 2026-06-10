// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qris_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QrisEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is QrisEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'QrisEvent()';
  }
}

/// @nodoc
class $QrisEventCopyWith<$Res> {
  $QrisEventCopyWith(QrisEvent _, $Res Function(QrisEvent) __);
}

/// Adds pattern-matching-related methods to [QrisEvent].
extension QrisEventPatterns on QrisEvent {
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
    TResult Function(_Started value)? started,
    TResult Function(_GenerateQRCode value)? generateQRCode,
    TResult Function(_CheckPaymentStatus value)? checkPaymentStatus,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started(_that);
      case _GenerateQRCode() when generateQRCode != null:
        return generateQRCode(_that);
      case _CheckPaymentStatus() when checkPaymentStatus != null:
        return checkPaymentStatus(_that);
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
    required TResult Function(_Started value) started,
    required TResult Function(_GenerateQRCode value) generateQRCode,
    required TResult Function(_CheckPaymentStatus value) checkPaymentStatus,
  }) {
    final _that = this;
    switch (_that) {
      case _Started():
        return started(_that);
      case _GenerateQRCode():
        return generateQRCode(_that);
      case _CheckPaymentStatus():
        return checkPaymentStatus(_that);
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
    TResult? Function(_Started value)? started,
    TResult? Function(_GenerateQRCode value)? generateQRCode,
    TResult? Function(_CheckPaymentStatus value)? checkPaymentStatus,
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started(_that);
      case _GenerateQRCode() when generateQRCode != null:
        return generateQRCode(_that);
      case _CheckPaymentStatus() when checkPaymentStatus != null:
        return checkPaymentStatus(_that);
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
    TResult Function()? started,
    TResult Function(String orderId, int grossAmount)? generateQRCode,
    TResult Function(String orderId)? checkPaymentStatus,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started();
      case _GenerateQRCode() when generateQRCode != null:
        return generateQRCode(_that.orderId, _that.grossAmount);
      case _CheckPaymentStatus() when checkPaymentStatus != null:
        return checkPaymentStatus(_that.orderId);
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
    required TResult Function() started,
    required TResult Function(String orderId, int grossAmount) generateQRCode,
    required TResult Function(String orderId) checkPaymentStatus,
  }) {
    final _that = this;
    switch (_that) {
      case _Started():
        return started();
      case _GenerateQRCode():
        return generateQRCode(_that.orderId, _that.grossAmount);
      case _CheckPaymentStatus():
        return checkPaymentStatus(_that.orderId);
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
    TResult? Function()? started,
    TResult? Function(String orderId, int grossAmount)? generateQRCode,
    TResult? Function(String orderId)? checkPaymentStatus,
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started();
      case _GenerateQRCode() when generateQRCode != null:
        return generateQRCode(_that.orderId, _that.grossAmount);
      case _CheckPaymentStatus() when checkPaymentStatus != null:
        return checkPaymentStatus(_that.orderId);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Started implements QrisEvent {
  const _Started();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Started);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'QrisEvent.started()';
  }
}

/// @nodoc

class _GenerateQRCode implements QrisEvent {
  const _GenerateQRCode(this.orderId, this.grossAmount);

  final String orderId;
  final int grossAmount;

  /// Create a copy of QrisEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GenerateQRCodeCopyWith<_GenerateQRCode> get copyWith =>
      __$GenerateQRCodeCopyWithImpl<_GenerateQRCode>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GenerateQRCode &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.grossAmount, grossAmount) ||
                other.grossAmount == grossAmount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, orderId, grossAmount);

  @override
  String toString() {
    return 'QrisEvent.generateQRCode(orderId: $orderId, grossAmount: $grossAmount)';
  }
}

/// @nodoc
abstract mixin class _$GenerateQRCodeCopyWith<$Res>
    implements $QrisEventCopyWith<$Res> {
  factory _$GenerateQRCodeCopyWith(
          _GenerateQRCode value, $Res Function(_GenerateQRCode) _then) =
      __$GenerateQRCodeCopyWithImpl;
  @useResult
  $Res call({String orderId, int grossAmount});
}

/// @nodoc
class __$GenerateQRCodeCopyWithImpl<$Res>
    implements _$GenerateQRCodeCopyWith<$Res> {
  __$GenerateQRCodeCopyWithImpl(this._self, this._then);

  final _GenerateQRCode _self;
  final $Res Function(_GenerateQRCode) _then;

  /// Create a copy of QrisEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? orderId = null,
    Object? grossAmount = null,
  }) {
    return _then(_GenerateQRCode(
      null == orderId
          ? _self.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      null == grossAmount
          ? _self.grossAmount
          : grossAmount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _CheckPaymentStatus implements QrisEvent {
  const _CheckPaymentStatus(this.orderId);

  final String orderId;

  /// Create a copy of QrisEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CheckPaymentStatusCopyWith<_CheckPaymentStatus> get copyWith =>
      __$CheckPaymentStatusCopyWithImpl<_CheckPaymentStatus>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CheckPaymentStatus &&
            (identical(other.orderId, orderId) || other.orderId == orderId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, orderId);

  @override
  String toString() {
    return 'QrisEvent.checkPaymentStatus(orderId: $orderId)';
  }
}

/// @nodoc
abstract mixin class _$CheckPaymentStatusCopyWith<$Res>
    implements $QrisEventCopyWith<$Res> {
  factory _$CheckPaymentStatusCopyWith(
          _CheckPaymentStatus value, $Res Function(_CheckPaymentStatus) _then) =
      __$CheckPaymentStatusCopyWithImpl;
  @useResult
  $Res call({String orderId});
}

/// @nodoc
class __$CheckPaymentStatusCopyWithImpl<$Res>
    implements _$CheckPaymentStatusCopyWith<$Res> {
  __$CheckPaymentStatusCopyWithImpl(this._self, this._then);

  final _CheckPaymentStatus _self;
  final $Res Function(_CheckPaymentStatus) _then;

  /// Create a copy of QrisEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? orderId = null,
  }) {
    return _then(_CheckPaymentStatus(
      null == orderId
          ? _self.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$QrisState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is QrisState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'QrisState()';
  }
}

/// @nodoc
class $QrisStateCopyWith<$Res> {
  $QrisStateCopyWith(QrisState _, $Res Function(QrisState) __);
}

/// Adds pattern-matching-related methods to [QrisState].
extension QrisStatePatterns on QrisState {
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
    TResult Function(_QrisResponse value)? qrisResponse,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    TResult Function(_StatusCheck value)? statusCheck,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case _Loading() when loading != null:
        return loading(_that);
      case _QrisResponse() when qrisResponse != null:
        return qrisResponse(_that);
      case _Success() when success != null:
        return success(_that);
      case _Error() when error != null:
        return error(_that);
      case _StatusCheck() when statusCheck != null:
        return statusCheck(_that);
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
    required TResult Function(_QrisResponse value) qrisResponse,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
    required TResult Function(_StatusCheck value) statusCheck,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial(_that);
      case _Loading():
        return loading(_that);
      case _QrisResponse():
        return qrisResponse(_that);
      case _Success():
        return success(_that);
      case _Error():
        return error(_that);
      case _StatusCheck():
        return statusCheck(_that);
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
    TResult? Function(_QrisResponse value)? qrisResponse,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
    TResult? Function(_StatusCheck value)? statusCheck,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case _Loading() when loading != null:
        return loading(_that);
      case _QrisResponse() when qrisResponse != null:
        return qrisResponse(_that);
      case _Success() when success != null:
        return success(_that);
      case _Error() when error != null:
        return error(_that);
      case _StatusCheck() when statusCheck != null:
        return statusCheck(_that);
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
    TResult Function(QrisResponseModel qrisResponseModel)? qrisResponse,
    TResult Function(String message)? success,
    TResult Function(String message)? error,
    TResult Function(QrisStatusResponseModel qrisStatusResponseModel)?
        statusCheck,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Loading() when loading != null:
        return loading();
      case _QrisResponse() when qrisResponse != null:
        return qrisResponse(_that.qrisResponseModel);
      case _Success() when success != null:
        return success(_that.message);
      case _Error() when error != null:
        return error(_that.message);
      case _StatusCheck() when statusCheck != null:
        return statusCheck(_that.qrisStatusResponseModel);
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
    required TResult Function(QrisResponseModel qrisResponseModel) qrisResponse,
    required TResult Function(String message) success,
    required TResult Function(String message) error,
    required TResult Function(QrisStatusResponseModel qrisStatusResponseModel)
        statusCheck,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial();
      case _Loading():
        return loading();
      case _QrisResponse():
        return qrisResponse(_that.qrisResponseModel);
      case _Success():
        return success(_that.message);
      case _Error():
        return error(_that.message);
      case _StatusCheck():
        return statusCheck(_that.qrisStatusResponseModel);
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
    TResult? Function(QrisResponseModel qrisResponseModel)? qrisResponse,
    TResult? Function(String message)? success,
    TResult? Function(String message)? error,
    TResult? Function(QrisStatusResponseModel qrisStatusResponseModel)?
        statusCheck,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Loading() when loading != null:
        return loading();
      case _QrisResponse() when qrisResponse != null:
        return qrisResponse(_that.qrisResponseModel);
      case _Success() when success != null:
        return success(_that.message);
      case _Error() when error != null:
        return error(_that.message);
      case _StatusCheck() when statusCheck != null:
        return statusCheck(_that.qrisStatusResponseModel);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Initial implements QrisState {
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
    return 'QrisState.initial()';
  }
}

/// @nodoc

class _Loading implements QrisState {
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
    return 'QrisState.loading()';
  }
}

/// @nodoc

class _QrisResponse implements QrisState {
  const _QrisResponse(this.qrisResponseModel);

  final QrisResponseModel qrisResponseModel;

  /// Create a copy of QrisState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$QrisResponseCopyWith<_QrisResponse> get copyWith =>
      __$QrisResponseCopyWithImpl<_QrisResponse>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _QrisResponse &&
            (identical(other.qrisResponseModel, qrisResponseModel) ||
                other.qrisResponseModel == qrisResponseModel));
  }

  @override
  int get hashCode => Object.hash(runtimeType, qrisResponseModel);

  @override
  String toString() {
    return 'QrisState.qrisResponse(qrisResponseModel: $qrisResponseModel)';
  }
}

/// @nodoc
abstract mixin class _$QrisResponseCopyWith<$Res>
    implements $QrisStateCopyWith<$Res> {
  factory _$QrisResponseCopyWith(
          _QrisResponse value, $Res Function(_QrisResponse) _then) =
      __$QrisResponseCopyWithImpl;
  @useResult
  $Res call({QrisResponseModel qrisResponseModel});
}

/// @nodoc
class __$QrisResponseCopyWithImpl<$Res>
    implements _$QrisResponseCopyWith<$Res> {
  __$QrisResponseCopyWithImpl(this._self, this._then);

  final _QrisResponse _self;
  final $Res Function(_QrisResponse) _then;

  /// Create a copy of QrisState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? qrisResponseModel = null,
  }) {
    return _then(_QrisResponse(
      null == qrisResponseModel
          ? _self.qrisResponseModel
          : qrisResponseModel // ignore: cast_nullable_to_non_nullable
              as QrisResponseModel,
    ));
  }
}

/// @nodoc

class _Success implements QrisState {
  const _Success(this.message);

  final String message;

  /// Create a copy of QrisState
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
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'QrisState.success(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$SuccessCopyWith<$Res>
    implements $QrisStateCopyWith<$Res> {
  factory _$SuccessCopyWith(_Success value, $Res Function(_Success) _then) =
      __$SuccessCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$SuccessCopyWithImpl<$Res> implements _$SuccessCopyWith<$Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success _self;
  final $Res Function(_Success) _then;

  /// Create a copy of QrisState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(_Success(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _Error implements QrisState {
  const _Error(this.message);

  final String message;

  /// Create a copy of QrisState
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
    return 'QrisState.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $QrisStateCopyWith<$Res> {
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

  /// Create a copy of QrisState
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

/// @nodoc

class _StatusCheck implements QrisState {
  const _StatusCheck(this.qrisStatusResponseModel);

  final QrisStatusResponseModel qrisStatusResponseModel;

  /// Create a copy of QrisState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StatusCheckCopyWith<_StatusCheck> get copyWith =>
      __$StatusCheckCopyWithImpl<_StatusCheck>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StatusCheck &&
            (identical(
                    other.qrisStatusResponseModel, qrisStatusResponseModel) ||
                other.qrisStatusResponseModel == qrisStatusResponseModel));
  }

  @override
  int get hashCode => Object.hash(runtimeType, qrisStatusResponseModel);

  @override
  String toString() {
    return 'QrisState.statusCheck(qrisStatusResponseModel: $qrisStatusResponseModel)';
  }
}

/// @nodoc
abstract mixin class _$StatusCheckCopyWith<$Res>
    implements $QrisStateCopyWith<$Res> {
  factory _$StatusCheckCopyWith(
          _StatusCheck value, $Res Function(_StatusCheck) _then) =
      __$StatusCheckCopyWithImpl;
  @useResult
  $Res call({QrisStatusResponseModel qrisStatusResponseModel});
}

/// @nodoc
class __$StatusCheckCopyWithImpl<$Res> implements _$StatusCheckCopyWith<$Res> {
  __$StatusCheckCopyWithImpl(this._self, this._then);

  final _StatusCheck _self;
  final $Res Function(_StatusCheck) _then;

  /// Create a copy of QrisState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? qrisStatusResponseModel = null,
  }) {
    return _then(_StatusCheck(
      null == qrisStatusResponseModel
          ? _self.qrisStatusResponseModel
          : qrisStatusResponseModel // ignore: cast_nullable_to_non_nullable
              as QrisStatusResponseModel,
    ));
  }
}

// dart format on
