// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckoutEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CheckoutEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CheckoutEvent()';
  }
}

/// @nodoc
class $CheckoutEventCopyWith<$Res> {
  $CheckoutEventCopyWith(CheckoutEvent _, $Res Function(CheckoutEvent) __);
}

/// Adds pattern-matching-related methods to [CheckoutEvent].
extension CheckoutEventPatterns on CheckoutEvent {
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
    TResult Function(_AddCheckout value)? addCheckout,
    TResult Function(_RemoveCheckout value)? removeCheckout,
    TResult Function(_RemoveProduct value)? removeProduct,
    TResult Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult Function(_LoadDraftOrder value)? loadDraftOrder,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started(_that);
      case _AddCheckout() when addCheckout != null:
        return addCheckout(_that);
      case _RemoveCheckout() when removeCheckout != null:
        return removeCheckout(_that);
      case _RemoveProduct() when removeProduct != null:
        return removeProduct(_that);
      case _SaveDraftOrder() when saveDraftOrder != null:
        return saveDraftOrder(_that);
      case _LoadDraftOrder() when loadDraftOrder != null:
        return loadDraftOrder(_that);
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
    required TResult Function(_AddCheckout value) addCheckout,
    required TResult Function(_RemoveCheckout value) removeCheckout,
    required TResult Function(_RemoveProduct value) removeProduct,
    required TResult Function(_SaveDraftOrder value) saveDraftOrder,
    required TResult Function(_LoadDraftOrder value) loadDraftOrder,
  }) {
    final _that = this;
    switch (_that) {
      case _Started():
        return started(_that);
      case _AddCheckout():
        return addCheckout(_that);
      case _RemoveCheckout():
        return removeCheckout(_that);
      case _RemoveProduct():
        return removeProduct(_that);
      case _SaveDraftOrder():
        return saveDraftOrder(_that);
      case _LoadDraftOrder():
        return loadDraftOrder(_that);
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
    TResult? Function(_AddCheckout value)? addCheckout,
    TResult? Function(_RemoveCheckout value)? removeCheckout,
    TResult? Function(_RemoveProduct value)? removeProduct,
    TResult? Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult? Function(_LoadDraftOrder value)? loadDraftOrder,
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started(_that);
      case _AddCheckout() when addCheckout != null:
        return addCheckout(_that);
      case _RemoveCheckout() when removeCheckout != null:
        return removeCheckout(_that);
      case _RemoveProduct() when removeProduct != null:
        return removeProduct(_that);
      case _SaveDraftOrder() when saveDraftOrder != null:
        return saveDraftOrder(_that);
      case _LoadDraftOrder() when loadDraftOrder != null:
        return loadDraftOrder(_that);
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
    TResult Function(Product product)? addCheckout,
    TResult Function(Product product)? removeCheckout,
    TResult Function(Product product)? removeProduct,
    TResult Function(String tableLabel, String customerName, int tableNumber)?
        saveDraftOrder,
    TResult Function(DraftOrderModel data)? loadDraftOrder,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started();
      case _AddCheckout() when addCheckout != null:
        return addCheckout(_that.product);
      case _RemoveCheckout() when removeCheckout != null:
        return removeCheckout(_that.product);
      case _RemoveProduct() when removeProduct != null:
        return removeProduct(_that.product);
      case _SaveDraftOrder() when saveDraftOrder != null:
        return saveDraftOrder(
            _that.tableLabel, _that.customerName, _that.tableNumber);
      case _LoadDraftOrder() when loadDraftOrder != null:
        return loadDraftOrder(_that.data);
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
    required TResult Function(Product product) addCheckout,
    required TResult Function(Product product) removeCheckout,
    required TResult Function(Product product) removeProduct,
    required TResult Function(
            String tableLabel, String customerName, int tableNumber)
        saveDraftOrder,
    required TResult Function(DraftOrderModel data) loadDraftOrder,
  }) {
    final _that = this;
    switch (_that) {
      case _Started():
        return started();
      case _AddCheckout():
        return addCheckout(_that.product);
      case _RemoveCheckout():
        return removeCheckout(_that.product);
      case _RemoveProduct():
        return removeProduct(_that.product);
      case _SaveDraftOrder():
        return saveDraftOrder(
            _that.tableLabel, _that.customerName, _that.tableNumber);
      case _LoadDraftOrder():
        return loadDraftOrder(_that.data);
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
    TResult? Function(Product product)? addCheckout,
    TResult? Function(Product product)? removeCheckout,
    TResult? Function(Product product)? removeProduct,
    TResult? Function(String tableLabel, String customerName, int tableNumber)?
        saveDraftOrder,
    TResult? Function(DraftOrderModel data)? loadDraftOrder,
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started();
      case _AddCheckout() when addCheckout != null:
        return addCheckout(_that.product);
      case _RemoveCheckout() when removeCheckout != null:
        return removeCheckout(_that.product);
      case _RemoveProduct() when removeProduct != null:
        return removeProduct(_that.product);
      case _SaveDraftOrder() when saveDraftOrder != null:
        return saveDraftOrder(
            _that.tableLabel, _that.customerName, _that.tableNumber);
      case _LoadDraftOrder() when loadDraftOrder != null:
        return loadDraftOrder(_that.data);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Started implements CheckoutEvent {
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
    return 'CheckoutEvent.started()';
  }
}

/// @nodoc

class _AddCheckout implements CheckoutEvent {
  const _AddCheckout(this.product);

  final Product product;

  /// Create a copy of CheckoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AddCheckoutCopyWith<_AddCheckout> get copyWith =>
      __$AddCheckoutCopyWithImpl<_AddCheckout>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AddCheckout &&
            (identical(other.product, product) || other.product == product));
  }

  @override
  int get hashCode => Object.hash(runtimeType, product);

  @override
  String toString() {
    return 'CheckoutEvent.addCheckout(product: $product)';
  }
}

/// @nodoc
abstract mixin class _$AddCheckoutCopyWith<$Res>
    implements $CheckoutEventCopyWith<$Res> {
  factory _$AddCheckoutCopyWith(
          _AddCheckout value, $Res Function(_AddCheckout) _then) =
      __$AddCheckoutCopyWithImpl;
  @useResult
  $Res call({Product product});
}

/// @nodoc
class __$AddCheckoutCopyWithImpl<$Res> implements _$AddCheckoutCopyWith<$Res> {
  __$AddCheckoutCopyWithImpl(this._self, this._then);

  final _AddCheckout _self;
  final $Res Function(_AddCheckout) _then;

  /// Create a copy of CheckoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? product = null,
  }) {
    return _then(_AddCheckout(
      null == product
          ? _self.product
          : product // ignore: cast_nullable_to_non_nullable
              as Product,
    ));
  }
}

/// @nodoc

class _RemoveCheckout implements CheckoutEvent {
  const _RemoveCheckout(this.product);

  final Product product;

  /// Create a copy of CheckoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RemoveCheckoutCopyWith<_RemoveCheckout> get copyWith =>
      __$RemoveCheckoutCopyWithImpl<_RemoveCheckout>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RemoveCheckout &&
            (identical(other.product, product) || other.product == product));
  }

  @override
  int get hashCode => Object.hash(runtimeType, product);

  @override
  String toString() {
    return 'CheckoutEvent.removeCheckout(product: $product)';
  }
}

/// @nodoc
abstract mixin class _$RemoveCheckoutCopyWith<$Res>
    implements $CheckoutEventCopyWith<$Res> {
  factory _$RemoveCheckoutCopyWith(
          _RemoveCheckout value, $Res Function(_RemoveCheckout) _then) =
      __$RemoveCheckoutCopyWithImpl;
  @useResult
  $Res call({Product product});
}

/// @nodoc
class __$RemoveCheckoutCopyWithImpl<$Res>
    implements _$RemoveCheckoutCopyWith<$Res> {
  __$RemoveCheckoutCopyWithImpl(this._self, this._then);

  final _RemoveCheckout _self;
  final $Res Function(_RemoveCheckout) _then;

  /// Create a copy of CheckoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? product = null,
  }) {
    return _then(_RemoveCheckout(
      null == product
          ? _self.product
          : product // ignore: cast_nullable_to_non_nullable
              as Product,
    ));
  }
}

/// @nodoc

class _RemoveProduct implements CheckoutEvent {
  const _RemoveProduct(this.product);

  final Product product;

  /// Create a copy of CheckoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RemoveProductCopyWith<_RemoveProduct> get copyWith =>
      __$RemoveProductCopyWithImpl<_RemoveProduct>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RemoveProduct &&
            (identical(other.product, product) || other.product == product));
  }

  @override
  int get hashCode => Object.hash(runtimeType, product);

  @override
  String toString() {
    return 'CheckoutEvent.removeProduct(product: $product)';
  }
}

/// @nodoc
abstract mixin class _$RemoveProductCopyWith<$Res>
    implements $CheckoutEventCopyWith<$Res> {
  factory _$RemoveProductCopyWith(
          _RemoveProduct value, $Res Function(_RemoveProduct) _then) =
      __$RemoveProductCopyWithImpl;
  @useResult
  $Res call({Product product});
}

/// @nodoc
class __$RemoveProductCopyWithImpl<$Res>
    implements _$RemoveProductCopyWith<$Res> {
  __$RemoveProductCopyWithImpl(this._self, this._then);

  final _RemoveProduct _self;
  final $Res Function(_RemoveProduct) _then;

  /// Create a copy of CheckoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? product = null,
  }) {
    return _then(_RemoveProduct(
      null == product
          ? _self.product
          : product // ignore: cast_nullable_to_non_nullable
              as Product,
    ));
  }
}

/// @nodoc

class _SaveDraftOrder implements CheckoutEvent {
  const _SaveDraftOrder(
      {this.tableLabel = '', this.customerName = '', this.tableNumber = 0});

  @JsonKey()
  final String tableLabel;
  @JsonKey()
  final String customerName;
  @JsonKey()
  final int tableNumber;

  /// Create a copy of CheckoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SaveDraftOrderCopyWith<_SaveDraftOrder> get copyWith =>
      __$SaveDraftOrderCopyWithImpl<_SaveDraftOrder>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SaveDraftOrder &&
            (identical(other.tableLabel, tableLabel) ||
                other.tableLabel == tableLabel) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.tableNumber, tableNumber) ||
                other.tableNumber == tableNumber));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, tableLabel, customerName, tableNumber);

  @override
  String toString() {
    return 'CheckoutEvent.saveDraftOrder(tableLabel: $tableLabel, customerName: $customerName, tableNumber: $tableNumber)';
  }
}

/// @nodoc
abstract mixin class _$SaveDraftOrderCopyWith<$Res>
    implements $CheckoutEventCopyWith<$Res> {
  factory _$SaveDraftOrderCopyWith(
          _SaveDraftOrder value, $Res Function(_SaveDraftOrder) _then) =
      __$SaveDraftOrderCopyWithImpl;
  @useResult
  $Res call({String tableLabel, String customerName, int tableNumber});
}

/// @nodoc
class __$SaveDraftOrderCopyWithImpl<$Res>
    implements _$SaveDraftOrderCopyWith<$Res> {
  __$SaveDraftOrderCopyWithImpl(this._self, this._then);

  final _SaveDraftOrder _self;
  final $Res Function(_SaveDraftOrder) _then;

  /// Create a copy of CheckoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? tableLabel = null,
    Object? customerName = null,
    Object? tableNumber = null,
  }) {
    return _then(_SaveDraftOrder(
      tableLabel: null == tableLabel
          ? _self.tableLabel
          : tableLabel // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      tableNumber: null == tableNumber
          ? _self.tableNumber
          : tableNumber // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _LoadDraftOrder implements CheckoutEvent {
  const _LoadDraftOrder(this.data);

  final DraftOrderModel data;

  /// Create a copy of CheckoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LoadDraftOrderCopyWith<_LoadDraftOrder> get copyWith =>
      __$LoadDraftOrderCopyWithImpl<_LoadDraftOrder>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LoadDraftOrder &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @override
  String toString() {
    return 'CheckoutEvent.loadDraftOrder(data: $data)';
  }
}

/// @nodoc
abstract mixin class _$LoadDraftOrderCopyWith<$Res>
    implements $CheckoutEventCopyWith<$Res> {
  factory _$LoadDraftOrderCopyWith(
          _LoadDraftOrder value, $Res Function(_LoadDraftOrder) _then) =
      __$LoadDraftOrderCopyWithImpl;
  @useResult
  $Res call({DraftOrderModel data});
}

/// @nodoc
class __$LoadDraftOrderCopyWithImpl<$Res>
    implements _$LoadDraftOrderCopyWith<$Res> {
  __$LoadDraftOrderCopyWithImpl(this._self, this._then);

  final _LoadDraftOrder _self;
  final $Res Function(_LoadDraftOrder) _then;

  /// Create a copy of CheckoutEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? data = null,
  }) {
    return _then(_LoadDraftOrder(
      null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as DraftOrderModel,
    ));
  }
}

/// @nodoc
mixin _$CheckoutState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CheckoutState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CheckoutState()';
  }
}

/// @nodoc
class $CheckoutStateCopyWith<$Res> {
  $CheckoutStateCopyWith(CheckoutState _, $Res Function(CheckoutState) __);
}

/// Adds pattern-matching-related methods to [CheckoutState].
extension CheckoutStatePatterns on CheckoutState {
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
    TResult Function(_SavedDraftOrder value)? savedDraftOrder,
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
      case _SavedDraftOrder() when savedDraftOrder != null:
        return savedDraftOrder(_that);
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
    required TResult Function(_SavedDraftOrder value) savedDraftOrder,
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
      case _SavedDraftOrder():
        return savedDraftOrder(_that);
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
    TResult? Function(_SavedDraftOrder value)? savedDraftOrder,
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
      case _SavedDraftOrder() when savedDraftOrder != null:
        return savedDraftOrder(_that);
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
    TResult Function(CheckoutSummary summary)? success,
    TResult Function(String message)? error,
    TResult Function()? savedDraftOrder,
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
      case _Error() when error != null:
        return error(_that.message);
      case _SavedDraftOrder() when savedDraftOrder != null:
        return savedDraftOrder();
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
    required TResult Function(CheckoutSummary summary) success,
    required TResult Function(String message) error,
    required TResult Function() savedDraftOrder,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial();
      case _Loading():
        return loading();
      case _Success():
        return success(_that.summary);
      case _Error():
        return error(_that.message);
      case _SavedDraftOrder():
        return savedDraftOrder();
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
    TResult? Function(CheckoutSummary summary)? success,
    TResult? Function(String message)? error,
    TResult? Function()? savedDraftOrder,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Loading() when loading != null:
        return loading();
      case _Success() when success != null:
        return success(_that.summary);
      case _Error() when error != null:
        return error(_that.message);
      case _SavedDraftOrder() when savedDraftOrder != null:
        return savedDraftOrder();
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Initial implements CheckoutState {
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
    return 'CheckoutState.initial()';
  }
}

/// @nodoc

class _Loading implements CheckoutState {
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
    return 'CheckoutState.loading()';
  }
}

/// @nodoc

class _Success implements CheckoutState {
  const _Success(this.summary);

  final CheckoutSummary summary;

  /// Create a copy of CheckoutState
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
    return 'CheckoutState.success(summary: $summary)';
  }
}

/// @nodoc
abstract mixin class _$SuccessCopyWith<$Res>
    implements $CheckoutStateCopyWith<$Res> {
  factory _$SuccessCopyWith(_Success value, $Res Function(_Success) _then) =
      __$SuccessCopyWithImpl;
  @useResult
  $Res call({CheckoutSummary summary});

  $CheckoutSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$SuccessCopyWithImpl<$Res> implements _$SuccessCopyWith<$Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success _self;
  final $Res Function(_Success) _then;

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? summary = null,
  }) {
    return _then(_Success(
      null == summary
          ? _self.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as CheckoutSummary,
    ));
  }

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckoutSummaryCopyWith<$Res> get summary {
    return $CheckoutSummaryCopyWith<$Res>(_self.summary, (value) {
      return _then(_self.copyWith(summary: value));
    });
  }
}

/// @nodoc

class _Error implements CheckoutState {
  const _Error(this.message);

  final String message;

  /// Create a copy of CheckoutState
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
    return 'CheckoutState.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res>
    implements $CheckoutStateCopyWith<$Res> {
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

  /// Create a copy of CheckoutState
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

class _SavedDraftOrder implements CheckoutState {
  const _SavedDraftOrder();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _SavedDraftOrder);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CheckoutState.savedDraftOrder()';
  }
}

// dart format on
