// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is OrderEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'OrderEvent()';
  }
}

/// @nodoc
class $OrderEventCopyWith<$Res> {
  $OrderEventCopyWith(OrderEvent _, $Res Function(OrderEvent) __);
}

/// Adds pattern-matching-related methods to [OrderEvent].
extension OrderEventPatterns on OrderEvent {
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
    TResult Function(_AddPaymentMethod value)? addPaymentMethod,
    TResult Function(_AddNominalBayar value)? addNominalBayar,
    TResult Function(_ApplyDiscount value)? applyDiscount,
    TResult Function(_ClearDiscount value)? clearDiscount,
    TResult Function(_PersistLocal value)? persistLocal,
    TResult Function(_Reset value)? reset,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started(_that);
      case _AddPaymentMethod() when addPaymentMethod != null:
        return addPaymentMethod(_that);
      case _AddNominalBayar() when addNominalBayar != null:
        return addNominalBayar(_that);
      case _ApplyDiscount() when applyDiscount != null:
        return applyDiscount(_that);
      case _ClearDiscount() when clearDiscount != null:
        return clearDiscount(_that);
      case _PersistLocal() when persistLocal != null:
        return persistLocal(_that);
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
    required TResult Function(_Started value) started,
    required TResult Function(_AddPaymentMethod value) addPaymentMethod,
    required TResult Function(_AddNominalBayar value) addNominalBayar,
    required TResult Function(_ApplyDiscount value) applyDiscount,
    required TResult Function(_ClearDiscount value) clearDiscount,
    required TResult Function(_PersistLocal value) persistLocal,
    required TResult Function(_Reset value) reset,
  }) {
    final _that = this;
    switch (_that) {
      case _Started():
        return started(_that);
      case _AddPaymentMethod():
        return addPaymentMethod(_that);
      case _AddNominalBayar():
        return addNominalBayar(_that);
      case _ApplyDiscount():
        return applyDiscount(_that);
      case _ClearDiscount():
        return clearDiscount(_that);
      case _PersistLocal():
        return persistLocal(_that);
      case _Reset():
        return reset(_that);
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
    TResult? Function(_AddPaymentMethod value)? addPaymentMethod,
    TResult? Function(_AddNominalBayar value)? addNominalBayar,
    TResult? Function(_ApplyDiscount value)? applyDiscount,
    TResult? Function(_ClearDiscount value)? clearDiscount,
    TResult? Function(_PersistLocal value)? persistLocal,
    TResult? Function(_Reset value)? reset,
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started(_that);
      case _AddPaymentMethod() when addPaymentMethod != null:
        return addPaymentMethod(_that);
      case _AddNominalBayar() when addNominalBayar != null:
        return addNominalBayar(_that);
      case _ApplyDiscount() when applyDiscount != null:
        return applyDiscount(_that);
      case _ClearDiscount() when clearDiscount != null:
        return clearDiscount(_that);
      case _PersistLocal() when persistLocal != null:
        return persistLocal(_that);
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
    TResult Function()? started,
    TResult Function(String paymentMethod, List<OrderItem> orders,
            String customerName, int? cashSessionId)?
        addPaymentMethod,
    TResult Function(int nominal)? addNominalBayar,
    TResult Function(AppliedDiscount discount)? applyDiscount,
    TResult Function()? clearDiscount,
    TResult Function()? persistLocal,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started();
      case _AddPaymentMethod() when addPaymentMethod != null:
        return addPaymentMethod(_that.paymentMethod, _that.orders,
            _that.customerName, _that.cashSessionId);
      case _AddNominalBayar() when addNominalBayar != null:
        return addNominalBayar(_that.nominal);
      case _ApplyDiscount() when applyDiscount != null:
        return applyDiscount(_that.discount);
      case _ClearDiscount() when clearDiscount != null:
        return clearDiscount();
      case _PersistLocal() when persistLocal != null:
        return persistLocal();
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
    required TResult Function() started,
    required TResult Function(String paymentMethod, List<OrderItem> orders,
            String customerName, int? cashSessionId)
        addPaymentMethod,
    required TResult Function(int nominal) addNominalBayar,
    required TResult Function(AppliedDiscount discount) applyDiscount,
    required TResult Function() clearDiscount,
    required TResult Function() persistLocal,
    required TResult Function() reset,
  }) {
    final _that = this;
    switch (_that) {
      case _Started():
        return started();
      case _AddPaymentMethod():
        return addPaymentMethod(_that.paymentMethod, _that.orders,
            _that.customerName, _that.cashSessionId);
      case _AddNominalBayar():
        return addNominalBayar(_that.nominal);
      case _ApplyDiscount():
        return applyDiscount(_that.discount);
      case _ClearDiscount():
        return clearDiscount();
      case _PersistLocal():
        return persistLocal();
      case _Reset():
        return reset();
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
    TResult? Function(String paymentMethod, List<OrderItem> orders,
            String customerName, int? cashSessionId)?
        addPaymentMethod,
    TResult? Function(int nominal)? addNominalBayar,
    TResult? Function(AppliedDiscount discount)? applyDiscount,
    TResult? Function()? clearDiscount,
    TResult? Function()? persistLocal,
    TResult? Function()? reset,
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started();
      case _AddPaymentMethod() when addPaymentMethod != null:
        return addPaymentMethod(_that.paymentMethod, _that.orders,
            _that.customerName, _that.cashSessionId);
      case _AddNominalBayar() when addNominalBayar != null:
        return addNominalBayar(_that.nominal);
      case _ApplyDiscount() when applyDiscount != null:
        return applyDiscount(_that.discount);
      case _ClearDiscount() when clearDiscount != null:
        return clearDiscount();
      case _PersistLocal() when persistLocal != null:
        return persistLocal();
      case _Reset() when reset != null:
        return reset();
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Started implements OrderEvent {
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
    return 'OrderEvent.started()';
  }
}

/// @nodoc

class _AddPaymentMethod implements OrderEvent {
  const _AddPaymentMethod(
      {required this.paymentMethod,
      required final List<OrderItem> orders,
      required this.customerName,
      required this.cashSessionId})
      : _orders = orders;

  final String paymentMethod;
  final List<OrderItem> _orders;
  List<OrderItem> get orders {
    if (_orders is EqualUnmodifiableListView) return _orders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_orders);
  }

  final String customerName;
  final int? cashSessionId;

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AddPaymentMethodCopyWith<_AddPaymentMethod> get copyWith =>
      __$AddPaymentMethodCopyWithImpl<_AddPaymentMethod>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AddPaymentMethod &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            const DeepCollectionEquality().equals(other._orders, _orders) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.cashSessionId, cashSessionId) ||
                other.cashSessionId == cashSessionId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      paymentMethod,
      const DeepCollectionEquality().hash(_orders),
      customerName,
      cashSessionId);

  @override
  String toString() {
    return 'OrderEvent.addPaymentMethod(paymentMethod: $paymentMethod, orders: $orders, customerName: $customerName, cashSessionId: $cashSessionId)';
  }
}

/// @nodoc
abstract mixin class _$AddPaymentMethodCopyWith<$Res>
    implements $OrderEventCopyWith<$Res> {
  factory _$AddPaymentMethodCopyWith(
          _AddPaymentMethod value, $Res Function(_AddPaymentMethod) _then) =
      __$AddPaymentMethodCopyWithImpl;
  @useResult
  $Res call(
      {String paymentMethod,
      List<OrderItem> orders,
      String customerName,
      int? cashSessionId});
}

/// @nodoc
class __$AddPaymentMethodCopyWithImpl<$Res>
    implements _$AddPaymentMethodCopyWith<$Res> {
  __$AddPaymentMethodCopyWithImpl(this._self, this._then);

  final _AddPaymentMethod _self;
  final $Res Function(_AddPaymentMethod) _then;

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? paymentMethod = null,
    Object? orders = null,
    Object? customerName = null,
    Object? cashSessionId = freezed,
  }) {
    return _then(_AddPaymentMethod(
      paymentMethod: null == paymentMethod
          ? _self.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      orders: null == orders
          ? _self._orders
          : orders // ignore: cast_nullable_to_non_nullable
              as List<OrderItem>,
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      cashSessionId: freezed == cashSessionId
          ? _self.cashSessionId
          : cashSessionId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _AddNominalBayar implements OrderEvent {
  const _AddNominalBayar(this.nominal);

  final int nominal;

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AddNominalBayarCopyWith<_AddNominalBayar> get copyWith =>
      __$AddNominalBayarCopyWithImpl<_AddNominalBayar>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AddNominalBayar &&
            (identical(other.nominal, nominal) || other.nominal == nominal));
  }

  @override
  int get hashCode => Object.hash(runtimeType, nominal);

  @override
  String toString() {
    return 'OrderEvent.addNominalBayar(nominal: $nominal)';
  }
}

/// @nodoc
abstract mixin class _$AddNominalBayarCopyWith<$Res>
    implements $OrderEventCopyWith<$Res> {
  factory _$AddNominalBayarCopyWith(
          _AddNominalBayar value, $Res Function(_AddNominalBayar) _then) =
      __$AddNominalBayarCopyWithImpl;
  @useResult
  $Res call({int nominal});
}

/// @nodoc
class __$AddNominalBayarCopyWithImpl<$Res>
    implements _$AddNominalBayarCopyWith<$Res> {
  __$AddNominalBayarCopyWithImpl(this._self, this._then);

  final _AddNominalBayar _self;
  final $Res Function(_AddNominalBayar) _then;

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? nominal = null,
  }) {
    return _then(_AddNominalBayar(
      null == nominal
          ? _self.nominal
          : nominal // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _ApplyDiscount implements OrderEvent {
  const _ApplyDiscount(this.discount);

  final AppliedDiscount discount;

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ApplyDiscountCopyWith<_ApplyDiscount> get copyWith =>
      __$ApplyDiscountCopyWithImpl<_ApplyDiscount>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ApplyDiscount &&
            (identical(other.discount, discount) ||
                other.discount == discount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, discount);

  @override
  String toString() {
    return 'OrderEvent.applyDiscount(discount: $discount)';
  }
}

/// @nodoc
abstract mixin class _$ApplyDiscountCopyWith<$Res>
    implements $OrderEventCopyWith<$Res> {
  factory _$ApplyDiscountCopyWith(
          _ApplyDiscount value, $Res Function(_ApplyDiscount) _then) =
      __$ApplyDiscountCopyWithImpl;
  @useResult
  $Res call({AppliedDiscount discount});

  $AppliedDiscountCopyWith<$Res> get discount;
}

/// @nodoc
class __$ApplyDiscountCopyWithImpl<$Res>
    implements _$ApplyDiscountCopyWith<$Res> {
  __$ApplyDiscountCopyWithImpl(this._self, this._then);

  final _ApplyDiscount _self;
  final $Res Function(_ApplyDiscount) _then;

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? discount = null,
  }) {
    return _then(_ApplyDiscount(
      null == discount
          ? _self.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as AppliedDiscount,
    ));
  }

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppliedDiscountCopyWith<$Res> get discount {
    return $AppliedDiscountCopyWith<$Res>(_self.discount, (value) {
      return _then(_self.copyWith(discount: value));
    });
  }
}

/// @nodoc

class _ClearDiscount implements OrderEvent {
  const _ClearDiscount();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _ClearDiscount);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'OrderEvent.clearDiscount()';
  }
}

/// @nodoc

class _PersistLocal implements OrderEvent {
  const _PersistLocal();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _PersistLocal);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'OrderEvent.persistLocal()';
  }
}

/// @nodoc

class _Reset implements OrderEvent {
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
    return 'OrderEvent.reset()';
  }
}

/// @nodoc
mixin _$OrderState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is OrderState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'OrderState()';
  }
}

/// @nodoc
class $OrderStateCopyWith<$Res> {
  $OrderStateCopyWith(OrderState _, $Res Function(OrderState) __);
}

/// Adds pattern-matching-related methods to [OrderState].
extension OrderStatePatterns on OrderState {
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
    TResult Function(_Persisted value)? persisted,
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
      case _Persisted() when persisted != null:
        return persisted(_that);
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
    required TResult Function(_Persisted value) persisted,
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
      case _Persisted():
        return persisted(_that);
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
    TResult? Function(_Persisted value)? persisted,
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
      case _Persisted() when persisted != null:
        return persisted(_that);
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
    TResult Function(OrderSummary summary)? success,
    TResult Function(int localOrderId, OrderSummary summary)? persisted,
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
        return success(_that.summary);
      case _Persisted() when persisted != null:
        return persisted(_that.localOrderId, _that.summary);
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
    required TResult Function(OrderSummary summary) success,
    required TResult Function(int localOrderId, OrderSummary summary) persisted,
    required TResult Function(String message) error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial();
      case _Loading():
        return loading();
      case _Success():
        return success(_that.summary);
      case _Persisted():
        return persisted(_that.localOrderId, _that.summary);
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
    TResult? Function(OrderSummary summary)? success,
    TResult? Function(int localOrderId, OrderSummary summary)? persisted,
    TResult? Function(String message)? error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Loading() when loading != null:
        return loading();
      case _Success() when success != null:
        return success(_that.summary);
      case _Persisted() when persisted != null:
        return persisted(_that.localOrderId, _that.summary);
      case _Error() when error != null:
        return error(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Initial implements OrderState {
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
    return 'OrderState.initial()';
  }
}

/// @nodoc

class _Loading implements OrderState {
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
    return 'OrderState.loading()';
  }
}

/// @nodoc

class _Success implements OrderState {
  const _Success(this.summary);

  final OrderSummary summary;

  /// Create a copy of OrderState
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
            (identical(other.summary, summary) || other.summary == summary));
  }

  @override
  int get hashCode => Object.hash(runtimeType, summary);

  @override
  String toString() {
    return 'OrderState.success(summary: $summary)';
  }
}

/// @nodoc
abstract mixin class _$SuccessCopyWith<$Res>
    implements $OrderStateCopyWith<$Res> {
  factory _$SuccessCopyWith(_Success value, $Res Function(_Success) _then) =
      __$SuccessCopyWithImpl;
  @useResult
  $Res call({OrderSummary summary});

  $OrderSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$SuccessCopyWithImpl<$Res> implements _$SuccessCopyWith<$Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success _self;
  final $Res Function(_Success) _then;

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? summary = null,
  }) {
    return _then(_Success(
      null == summary
          ? _self.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as OrderSummary,
    ));
  }

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderSummaryCopyWith<$Res> get summary {
    return $OrderSummaryCopyWith<$Res>(_self.summary, (value) {
      return _then(_self.copyWith(summary: value));
    });
  }
}

/// @nodoc

class _Persisted implements OrderState {
  const _Persisted(this.localOrderId, this.summary);

  final int localOrderId;
  final OrderSummary summary;

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PersistedCopyWith<_Persisted> get copyWith =>
      __$PersistedCopyWithImpl<_Persisted>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Persisted &&
            (identical(other.localOrderId, localOrderId) ||
                other.localOrderId == localOrderId) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @override
  int get hashCode => Object.hash(runtimeType, localOrderId, summary);

  @override
  String toString() {
    return 'OrderState.persisted(localOrderId: $localOrderId, summary: $summary)';
  }
}

/// @nodoc
abstract mixin class _$PersistedCopyWith<$Res>
    implements $OrderStateCopyWith<$Res> {
  factory _$PersistedCopyWith(
          _Persisted value, $Res Function(_Persisted) _then) =
      __$PersistedCopyWithImpl;
  @useResult
  $Res call({int localOrderId, OrderSummary summary});

  $OrderSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$PersistedCopyWithImpl<$Res> implements _$PersistedCopyWith<$Res> {
  __$PersistedCopyWithImpl(this._self, this._then);

  final _Persisted _self;
  final $Res Function(_Persisted) _then;

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? localOrderId = null,
    Object? summary = null,
  }) {
    return _then(_Persisted(
      null == localOrderId
          ? _self.localOrderId
          : localOrderId // ignore: cast_nullable_to_non_nullable
              as int,
      null == summary
          ? _self.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as OrderSummary,
    ));
  }

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderSummaryCopyWith<$Res> get summary {
    return $OrderSummaryCopyWith<$Res>(_self.summary, (value) {
      return _then(_self.copyWith(summary: value));
    });
  }
}

/// @nodoc

class _Error implements OrderState {
  const _Error(this.message);

  final String message;

  /// Create a copy of OrderState
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
    return 'OrderState.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res>
    implements $OrderStateCopyWith<$Res> {
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

  /// Create a copy of OrderState
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
