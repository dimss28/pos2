// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderSummary {
  List<OrderItem> get products;
  int get totalQuantity;
  int get totalPrice;
  String get paymentMethod;
  int get nominalBayar;
  int get idKasir;
  String get namaKasir;
  String get customerName;

  /// Set by the page that triggers payment, from the current open shift.
  /// Required when persisting to local DB.
  int? get cashSessionId;

  /// Discount applied via voucher / auto-promo / manual entry.
  /// Bloc rebuilds [totalPrice] using `subtotal − appliedDiscount.amount`,
  /// so [totalPrice] is always the final tagihan AFTER promo.
  AppliedDiscount? get appliedDiscount;

  /// Create a copy of OrderSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OrderSummaryCopyWith<OrderSummary> get copyWith =>
      _$OrderSummaryCopyWithImpl<OrderSummary>(
          this as OrderSummary, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OrderSummary &&
            const DeepCollectionEquality().equals(other.products, products) &&
            (identical(other.totalQuantity, totalQuantity) ||
                other.totalQuantity == totalQuantity) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.nominalBayar, nominalBayar) ||
                other.nominalBayar == nominalBayar) &&
            (identical(other.idKasir, idKasir) || other.idKasir == idKasir) &&
            (identical(other.namaKasir, namaKasir) ||
                other.namaKasir == namaKasir) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.cashSessionId, cashSessionId) ||
                other.cashSessionId == cashSessionId) &&
            (identical(other.appliedDiscount, appliedDiscount) ||
                other.appliedDiscount == appliedDiscount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(products),
      totalQuantity,
      totalPrice,
      paymentMethod,
      nominalBayar,
      idKasir,
      namaKasir,
      customerName,
      cashSessionId,
      appliedDiscount);

  @override
  String toString() {
    return 'OrderSummary(products: $products, totalQuantity: $totalQuantity, totalPrice: $totalPrice, paymentMethod: $paymentMethod, nominalBayar: $nominalBayar, idKasir: $idKasir, namaKasir: $namaKasir, customerName: $customerName, cashSessionId: $cashSessionId, appliedDiscount: $appliedDiscount)';
  }
}

/// @nodoc
abstract mixin class $OrderSummaryCopyWith<$Res> {
  factory $OrderSummaryCopyWith(
          OrderSummary value, $Res Function(OrderSummary) _then) =
      _$OrderSummaryCopyWithImpl;
  @useResult
  $Res call(
      {List<OrderItem> products,
      int totalQuantity,
      int totalPrice,
      String paymentMethod,
      int nominalBayar,
      int idKasir,
      String namaKasir,
      String customerName,
      int? cashSessionId,
      AppliedDiscount? appliedDiscount});

  $AppliedDiscountCopyWith<$Res>? get appliedDiscount;
}

/// @nodoc
class _$OrderSummaryCopyWithImpl<$Res> implements $OrderSummaryCopyWith<$Res> {
  _$OrderSummaryCopyWithImpl(this._self, this._then);

  final OrderSummary _self;
  final $Res Function(OrderSummary) _then;

  /// Create a copy of OrderSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? products = null,
    Object? totalQuantity = null,
    Object? totalPrice = null,
    Object? paymentMethod = null,
    Object? nominalBayar = null,
    Object? idKasir = null,
    Object? namaKasir = null,
    Object? customerName = null,
    Object? cashSessionId = freezed,
    Object? appliedDiscount = freezed,
  }) {
    return _then(_self.copyWith(
      products: null == products
          ? _self.products
          : products // ignore: cast_nullable_to_non_nullable
              as List<OrderItem>,
      totalQuantity: null == totalQuantity
          ? _self.totalQuantity
          : totalQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      totalPrice: null == totalPrice
          ? _self.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as int,
      paymentMethod: null == paymentMethod
          ? _self.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      nominalBayar: null == nominalBayar
          ? _self.nominalBayar
          : nominalBayar // ignore: cast_nullable_to_non_nullable
              as int,
      idKasir: null == idKasir
          ? _self.idKasir
          : idKasir // ignore: cast_nullable_to_non_nullable
              as int,
      namaKasir: null == namaKasir
          ? _self.namaKasir
          : namaKasir // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      cashSessionId: freezed == cashSessionId
          ? _self.cashSessionId
          : cashSessionId // ignore: cast_nullable_to_non_nullable
              as int?,
      appliedDiscount: freezed == appliedDiscount
          ? _self.appliedDiscount
          : appliedDiscount // ignore: cast_nullable_to_non_nullable
              as AppliedDiscount?,
    ));
  }

  /// Create a copy of OrderSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppliedDiscountCopyWith<$Res>? get appliedDiscount {
    if (_self.appliedDiscount == null) {
      return null;
    }

    return $AppliedDiscountCopyWith<$Res>(_self.appliedDiscount!, (value) {
      return _then(_self.copyWith(appliedDiscount: value));
    });
  }
}

/// Adds pattern-matching-related methods to [OrderSummary].
extension OrderSummaryPatterns on OrderSummary {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_OrderSummary value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OrderSummary() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_OrderSummary value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderSummary():
        return $default(_that);
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
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_OrderSummary value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderSummary() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            List<OrderItem> products,
            int totalQuantity,
            int totalPrice,
            String paymentMethod,
            int nominalBayar,
            int idKasir,
            String namaKasir,
            String customerName,
            int? cashSessionId,
            AppliedDiscount? appliedDiscount)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OrderSummary() when $default != null:
        return $default(
            _that.products,
            _that.totalQuantity,
            _that.totalPrice,
            _that.paymentMethod,
            _that.nominalBayar,
            _that.idKasir,
            _that.namaKasir,
            _that.customerName,
            _that.cashSessionId,
            _that.appliedDiscount);
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
  TResult when<TResult extends Object?>(
    TResult Function(
            List<OrderItem> products,
            int totalQuantity,
            int totalPrice,
            String paymentMethod,
            int nominalBayar,
            int idKasir,
            String namaKasir,
            String customerName,
            int? cashSessionId,
            AppliedDiscount? appliedDiscount)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderSummary():
        return $default(
            _that.products,
            _that.totalQuantity,
            _that.totalPrice,
            _that.paymentMethod,
            _that.nominalBayar,
            _that.idKasir,
            _that.namaKasir,
            _that.customerName,
            _that.cashSessionId,
            _that.appliedDiscount);
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
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            List<OrderItem> products,
            int totalQuantity,
            int totalPrice,
            String paymentMethod,
            int nominalBayar,
            int idKasir,
            String namaKasir,
            String customerName,
            int? cashSessionId,
            AppliedDiscount? appliedDiscount)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderSummary() when $default != null:
        return $default(
            _that.products,
            _that.totalQuantity,
            _that.totalPrice,
            _that.paymentMethod,
            _that.nominalBayar,
            _that.idKasir,
            _that.namaKasir,
            _that.customerName,
            _that.cashSessionId,
            _that.appliedDiscount);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OrderSummary extends OrderSummary {
  const _OrderSummary(
      {final List<OrderItem> products = const <OrderItem>[],
      this.totalQuantity = 0,
      this.totalPrice = 0,
      this.paymentMethod = '',
      this.nominalBayar = 0,
      this.idKasir = 0,
      this.namaKasir = '',
      this.customerName = '',
      this.cashSessionId,
      this.appliedDiscount})
      : _products = products,
        super._();

  final List<OrderItem> _products;
  @override
  @JsonKey()
  List<OrderItem> get products {
    if (_products is EqualUnmodifiableListView) return _products;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_products);
  }

  @override
  @JsonKey()
  final int totalQuantity;
  @override
  @JsonKey()
  final int totalPrice;
  @override
  @JsonKey()
  final String paymentMethod;
  @override
  @JsonKey()
  final int nominalBayar;
  @override
  @JsonKey()
  final int idKasir;
  @override
  @JsonKey()
  final String namaKasir;
  @override
  @JsonKey()
  final String customerName;

  /// Set by the page that triggers payment, from the current open shift.
  /// Required when persisting to local DB.
  @override
  final int? cashSessionId;

  /// Discount applied via voucher / auto-promo / manual entry.
  /// Bloc rebuilds [totalPrice] using `subtotal − appliedDiscount.amount`,
  /// so [totalPrice] is always the final tagihan AFTER promo.
  @override
  final AppliedDiscount? appliedDiscount;

  /// Create a copy of OrderSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OrderSummaryCopyWith<_OrderSummary> get copyWith =>
      __$OrderSummaryCopyWithImpl<_OrderSummary>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OrderSummary &&
            const DeepCollectionEquality().equals(other._products, _products) &&
            (identical(other.totalQuantity, totalQuantity) ||
                other.totalQuantity == totalQuantity) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.nominalBayar, nominalBayar) ||
                other.nominalBayar == nominalBayar) &&
            (identical(other.idKasir, idKasir) || other.idKasir == idKasir) &&
            (identical(other.namaKasir, namaKasir) ||
                other.namaKasir == namaKasir) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.cashSessionId, cashSessionId) ||
                other.cashSessionId == cashSessionId) &&
            (identical(other.appliedDiscount, appliedDiscount) ||
                other.appliedDiscount == appliedDiscount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_products),
      totalQuantity,
      totalPrice,
      paymentMethod,
      nominalBayar,
      idKasir,
      namaKasir,
      customerName,
      cashSessionId,
      appliedDiscount);

  @override
  String toString() {
    return 'OrderSummary(products: $products, totalQuantity: $totalQuantity, totalPrice: $totalPrice, paymentMethod: $paymentMethod, nominalBayar: $nominalBayar, idKasir: $idKasir, namaKasir: $namaKasir, customerName: $customerName, cashSessionId: $cashSessionId, appliedDiscount: $appliedDiscount)';
  }
}

/// @nodoc
abstract mixin class _$OrderSummaryCopyWith<$Res>
    implements $OrderSummaryCopyWith<$Res> {
  factory _$OrderSummaryCopyWith(
          _OrderSummary value, $Res Function(_OrderSummary) _then) =
      __$OrderSummaryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<OrderItem> products,
      int totalQuantity,
      int totalPrice,
      String paymentMethod,
      int nominalBayar,
      int idKasir,
      String namaKasir,
      String customerName,
      int? cashSessionId,
      AppliedDiscount? appliedDiscount});

  @override
  $AppliedDiscountCopyWith<$Res>? get appliedDiscount;
}

/// @nodoc
class __$OrderSummaryCopyWithImpl<$Res>
    implements _$OrderSummaryCopyWith<$Res> {
  __$OrderSummaryCopyWithImpl(this._self, this._then);

  final _OrderSummary _self;
  final $Res Function(_OrderSummary) _then;

  /// Create a copy of OrderSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? products = null,
    Object? totalQuantity = null,
    Object? totalPrice = null,
    Object? paymentMethod = null,
    Object? nominalBayar = null,
    Object? idKasir = null,
    Object? namaKasir = null,
    Object? customerName = null,
    Object? cashSessionId = freezed,
    Object? appliedDiscount = freezed,
  }) {
    return _then(_OrderSummary(
      products: null == products
          ? _self._products
          : products // ignore: cast_nullable_to_non_nullable
              as List<OrderItem>,
      totalQuantity: null == totalQuantity
          ? _self.totalQuantity
          : totalQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      totalPrice: null == totalPrice
          ? _self.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as int,
      paymentMethod: null == paymentMethod
          ? _self.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      nominalBayar: null == nominalBayar
          ? _self.nominalBayar
          : nominalBayar // ignore: cast_nullable_to_non_nullable
              as int,
      idKasir: null == idKasir
          ? _self.idKasir
          : idKasir // ignore: cast_nullable_to_non_nullable
              as int,
      namaKasir: null == namaKasir
          ? _self.namaKasir
          : namaKasir // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      cashSessionId: freezed == cashSessionId
          ? _self.cashSessionId
          : cashSessionId // ignore: cast_nullable_to_non_nullable
              as int?,
      appliedDiscount: freezed == appliedDiscount
          ? _self.appliedDiscount
          : appliedDiscount // ignore: cast_nullable_to_non_nullable
              as AppliedDiscount?,
    ));
  }

  /// Create a copy of OrderSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppliedDiscountCopyWith<$Res>? get appliedDiscount {
    if (_self.appliedDiscount == null) {
      return null;
    }

    return $AppliedDiscountCopyWith<$Res>(_self.appliedDiscount!, (value) {
      return _then(_self.copyWith(appliedDiscount: value));
    });
  }
}

// dart format on
