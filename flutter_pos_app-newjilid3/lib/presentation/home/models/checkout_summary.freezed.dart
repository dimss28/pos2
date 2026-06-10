// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckoutSummary {
  List<OrderItem> get products;
  int get totalQuantity;
  int get totalPrice;
  String get draftName;

  /// Source draft id when the cart was loaded from an existing Open Bill.
  /// Saving the cart updates this row instead of creating a duplicate;
  /// paying it out deletes this row.
  int? get linkedDraftId;
  String? get linkedTableLabel;
  String? get linkedCustomerName;

  /// Create a copy of CheckoutSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CheckoutSummaryCopyWith<CheckoutSummary> get copyWith =>
      _$CheckoutSummaryCopyWithImpl<CheckoutSummary>(
          this as CheckoutSummary, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CheckoutSummary &&
            const DeepCollectionEquality().equals(other.products, products) &&
            (identical(other.totalQuantity, totalQuantity) ||
                other.totalQuantity == totalQuantity) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.draftName, draftName) ||
                other.draftName == draftName) &&
            (identical(other.linkedDraftId, linkedDraftId) ||
                other.linkedDraftId == linkedDraftId) &&
            (identical(other.linkedTableLabel, linkedTableLabel) ||
                other.linkedTableLabel == linkedTableLabel) &&
            (identical(other.linkedCustomerName, linkedCustomerName) ||
                other.linkedCustomerName == linkedCustomerName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(products),
      totalQuantity,
      totalPrice,
      draftName,
      linkedDraftId,
      linkedTableLabel,
      linkedCustomerName);

  @override
  String toString() {
    return 'CheckoutSummary(products: $products, totalQuantity: $totalQuantity, totalPrice: $totalPrice, draftName: $draftName, linkedDraftId: $linkedDraftId, linkedTableLabel: $linkedTableLabel, linkedCustomerName: $linkedCustomerName)';
  }
}

/// @nodoc
abstract mixin class $CheckoutSummaryCopyWith<$Res> {
  factory $CheckoutSummaryCopyWith(
          CheckoutSummary value, $Res Function(CheckoutSummary) _then) =
      _$CheckoutSummaryCopyWithImpl;
  @useResult
  $Res call(
      {List<OrderItem> products,
      int totalQuantity,
      int totalPrice,
      String draftName,
      int? linkedDraftId,
      String? linkedTableLabel,
      String? linkedCustomerName});
}

/// @nodoc
class _$CheckoutSummaryCopyWithImpl<$Res>
    implements $CheckoutSummaryCopyWith<$Res> {
  _$CheckoutSummaryCopyWithImpl(this._self, this._then);

  final CheckoutSummary _self;
  final $Res Function(CheckoutSummary) _then;

  /// Create a copy of CheckoutSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? products = null,
    Object? totalQuantity = null,
    Object? totalPrice = null,
    Object? draftName = null,
    Object? linkedDraftId = freezed,
    Object? linkedTableLabel = freezed,
    Object? linkedCustomerName = freezed,
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
      draftName: null == draftName
          ? _self.draftName
          : draftName // ignore: cast_nullable_to_non_nullable
              as String,
      linkedDraftId: freezed == linkedDraftId
          ? _self.linkedDraftId
          : linkedDraftId // ignore: cast_nullable_to_non_nullable
              as int?,
      linkedTableLabel: freezed == linkedTableLabel
          ? _self.linkedTableLabel
          : linkedTableLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      linkedCustomerName: freezed == linkedCustomerName
          ? _self.linkedCustomerName
          : linkedCustomerName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [CheckoutSummary].
extension CheckoutSummaryPatterns on CheckoutSummary {
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
    TResult Function(_CheckoutSummary value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckoutSummary() when $default != null:
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
    TResult Function(_CheckoutSummary value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckoutSummary():
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
    TResult? Function(_CheckoutSummary value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckoutSummary() when $default != null:
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
            String draftName,
            int? linkedDraftId,
            String? linkedTableLabel,
            String? linkedCustomerName)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckoutSummary() when $default != null:
        return $default(
            _that.products,
            _that.totalQuantity,
            _that.totalPrice,
            _that.draftName,
            _that.linkedDraftId,
            _that.linkedTableLabel,
            _that.linkedCustomerName);
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
            String draftName,
            int? linkedDraftId,
            String? linkedTableLabel,
            String? linkedCustomerName)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckoutSummary():
        return $default(
            _that.products,
            _that.totalQuantity,
            _that.totalPrice,
            _that.draftName,
            _that.linkedDraftId,
            _that.linkedTableLabel,
            _that.linkedCustomerName);
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
            String draftName,
            int? linkedDraftId,
            String? linkedTableLabel,
            String? linkedCustomerName)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckoutSummary() when $default != null:
        return $default(
            _that.products,
            _that.totalQuantity,
            _that.totalPrice,
            _that.draftName,
            _that.linkedDraftId,
            _that.linkedTableLabel,
            _that.linkedCustomerName);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CheckoutSummary extends CheckoutSummary {
  const _CheckoutSummary(
      {final List<OrderItem> products = const <OrderItem>[],
      this.totalQuantity = 0,
      this.totalPrice = 0,
      this.draftName = 'customer',
      this.linkedDraftId,
      this.linkedTableLabel,
      this.linkedCustomerName})
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
  final String draftName;

  /// Source draft id when the cart was loaded from an existing Open Bill.
  /// Saving the cart updates this row instead of creating a duplicate;
  /// paying it out deletes this row.
  @override
  final int? linkedDraftId;
  @override
  final String? linkedTableLabel;
  @override
  final String? linkedCustomerName;

  /// Create a copy of CheckoutSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CheckoutSummaryCopyWith<_CheckoutSummary> get copyWith =>
      __$CheckoutSummaryCopyWithImpl<_CheckoutSummary>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CheckoutSummary &&
            const DeepCollectionEquality().equals(other._products, _products) &&
            (identical(other.totalQuantity, totalQuantity) ||
                other.totalQuantity == totalQuantity) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.draftName, draftName) ||
                other.draftName == draftName) &&
            (identical(other.linkedDraftId, linkedDraftId) ||
                other.linkedDraftId == linkedDraftId) &&
            (identical(other.linkedTableLabel, linkedTableLabel) ||
                other.linkedTableLabel == linkedTableLabel) &&
            (identical(other.linkedCustomerName, linkedCustomerName) ||
                other.linkedCustomerName == linkedCustomerName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_products),
      totalQuantity,
      totalPrice,
      draftName,
      linkedDraftId,
      linkedTableLabel,
      linkedCustomerName);

  @override
  String toString() {
    return 'CheckoutSummary(products: $products, totalQuantity: $totalQuantity, totalPrice: $totalPrice, draftName: $draftName, linkedDraftId: $linkedDraftId, linkedTableLabel: $linkedTableLabel, linkedCustomerName: $linkedCustomerName)';
  }
}

/// @nodoc
abstract mixin class _$CheckoutSummaryCopyWith<$Res>
    implements $CheckoutSummaryCopyWith<$Res> {
  factory _$CheckoutSummaryCopyWith(
          _CheckoutSummary value, $Res Function(_CheckoutSummary) _then) =
      __$CheckoutSummaryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<OrderItem> products,
      int totalQuantity,
      int totalPrice,
      String draftName,
      int? linkedDraftId,
      String? linkedTableLabel,
      String? linkedCustomerName});
}

/// @nodoc
class __$CheckoutSummaryCopyWithImpl<$Res>
    implements _$CheckoutSummaryCopyWith<$Res> {
  __$CheckoutSummaryCopyWithImpl(this._self, this._then);

  final _CheckoutSummary _self;
  final $Res Function(_CheckoutSummary) _then;

  /// Create a copy of CheckoutSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? products = null,
    Object? totalQuantity = null,
    Object? totalPrice = null,
    Object? draftName = null,
    Object? linkedDraftId = freezed,
    Object? linkedTableLabel = freezed,
    Object? linkedCustomerName = freezed,
  }) {
    return _then(_CheckoutSummary(
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
      draftName: null == draftName
          ? _self.draftName
          : draftName // ignore: cast_nullable_to_non_nullable
              as String,
      linkedDraftId: freezed == linkedDraftId
          ? _self.linkedDraftId
          : linkedDraftId // ignore: cast_nullable_to_non_nullable
              as int?,
      linkedTableLabel: freezed == linkedTableLabel
          ? _self.linkedTableLabel
          : linkedTableLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      linkedCustomerName: freezed == linkedCustomerName
          ? _self.linkedCustomerName
          : linkedCustomerName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
