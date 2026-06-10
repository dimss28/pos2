// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ProductEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ProductEvent()';
  }
}

/// @nodoc
class $ProductEventCopyWith<$Res> {
  $ProductEventCopyWith(ProductEvent _, $Res Function(ProductEvent) __);
}

/// Adds pattern-matching-related methods to [ProductEvent].
extension ProductEventPatterns on ProductEvent {
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
    TResult Function(_Fetch value)? fetch,
    TResult Function(_FetchByCategory value)? fetchByCategory,
    TResult Function(_FetchLocal value)? fetchLocal,
    TResult Function(_AddProduct value)? addProduct,
    TResult Function(_UpdateProduct value)? updateProduct,
    TResult Function(_SearchProduct value)? searchProduct,
    TResult Function(_FetchAllFromState value)? fetchAllFromState,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started(_that);
      case _Fetch() when fetch != null:
        return fetch(_that);
      case _FetchByCategory() when fetchByCategory != null:
        return fetchByCategory(_that);
      case _FetchLocal() when fetchLocal != null:
        return fetchLocal(_that);
      case _AddProduct() when addProduct != null:
        return addProduct(_that);
      case _UpdateProduct() when updateProduct != null:
        return updateProduct(_that);
      case _SearchProduct() when searchProduct != null:
        return searchProduct(_that);
      case _FetchAllFromState() when fetchAllFromState != null:
        return fetchAllFromState(_that);
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
    required TResult Function(_Fetch value) fetch,
    required TResult Function(_FetchByCategory value) fetchByCategory,
    required TResult Function(_FetchLocal value) fetchLocal,
    required TResult Function(_AddProduct value) addProduct,
    required TResult Function(_UpdateProduct value) updateProduct,
    required TResult Function(_SearchProduct value) searchProduct,
    required TResult Function(_FetchAllFromState value) fetchAllFromState,
  }) {
    final _that = this;
    switch (_that) {
      case _Started():
        return started(_that);
      case _Fetch():
        return fetch(_that);
      case _FetchByCategory():
        return fetchByCategory(_that);
      case _FetchLocal():
        return fetchLocal(_that);
      case _AddProduct():
        return addProduct(_that);
      case _UpdateProduct():
        return updateProduct(_that);
      case _SearchProduct():
        return searchProduct(_that);
      case _FetchAllFromState():
        return fetchAllFromState(_that);
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
    TResult? Function(_Fetch value)? fetch,
    TResult? Function(_FetchByCategory value)? fetchByCategory,
    TResult? Function(_FetchLocal value)? fetchLocal,
    TResult? Function(_AddProduct value)? addProduct,
    TResult? Function(_UpdateProduct value)? updateProduct,
    TResult? Function(_SearchProduct value)? searchProduct,
    TResult? Function(_FetchAllFromState value)? fetchAllFromState,
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started(_that);
      case _Fetch() when fetch != null:
        return fetch(_that);
      case _FetchByCategory() when fetchByCategory != null:
        return fetchByCategory(_that);
      case _FetchLocal() when fetchLocal != null:
        return fetchLocal(_that);
      case _AddProduct() when addProduct != null:
        return addProduct(_that);
      case _UpdateProduct() when updateProduct != null:
        return updateProduct(_that);
      case _SearchProduct() when searchProduct != null:
        return searchProduct(_that);
      case _FetchAllFromState() when fetchAllFromState != null:
        return fetchAllFromState(_that);
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
    TResult Function()? fetch,
    TResult Function(String category)? fetchByCategory,
    TResult Function()? fetchLocal,
    TResult Function(Product product, XFile image)? addProduct,
    TResult Function(int productId, Product product, XFile? image)?
        updateProduct,
    TResult Function(String query)? searchProduct,
    TResult Function()? fetchAllFromState,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started();
      case _Fetch() when fetch != null:
        return fetch();
      case _FetchByCategory() when fetchByCategory != null:
        return fetchByCategory(_that.category);
      case _FetchLocal() when fetchLocal != null:
        return fetchLocal();
      case _AddProduct() when addProduct != null:
        return addProduct(_that.product, _that.image);
      case _UpdateProduct() when updateProduct != null:
        return updateProduct(_that.productId, _that.product, _that.image);
      case _SearchProduct() when searchProduct != null:
        return searchProduct(_that.query);
      case _FetchAllFromState() when fetchAllFromState != null:
        return fetchAllFromState();
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
    required TResult Function() fetch,
    required TResult Function(String category) fetchByCategory,
    required TResult Function() fetchLocal,
    required TResult Function(Product product, XFile image) addProduct,
    required TResult Function(int productId, Product product, XFile? image)
        updateProduct,
    required TResult Function(String query) searchProduct,
    required TResult Function() fetchAllFromState,
  }) {
    final _that = this;
    switch (_that) {
      case _Started():
        return started();
      case _Fetch():
        return fetch();
      case _FetchByCategory():
        return fetchByCategory(_that.category);
      case _FetchLocal():
        return fetchLocal();
      case _AddProduct():
        return addProduct(_that.product, _that.image);
      case _UpdateProduct():
        return updateProduct(_that.productId, _that.product, _that.image);
      case _SearchProduct():
        return searchProduct(_that.query);
      case _FetchAllFromState():
        return fetchAllFromState();
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
    TResult? Function()? fetch,
    TResult? Function(String category)? fetchByCategory,
    TResult? Function()? fetchLocal,
    TResult? Function(Product product, XFile image)? addProduct,
    TResult? Function(int productId, Product product, XFile? image)?
        updateProduct,
    TResult? Function(String query)? searchProduct,
    TResult? Function()? fetchAllFromState,
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started();
      case _Fetch() when fetch != null:
        return fetch();
      case _FetchByCategory() when fetchByCategory != null:
        return fetchByCategory(_that.category);
      case _FetchLocal() when fetchLocal != null:
        return fetchLocal();
      case _AddProduct() when addProduct != null:
        return addProduct(_that.product, _that.image);
      case _UpdateProduct() when updateProduct != null:
        return updateProduct(_that.productId, _that.product, _that.image);
      case _SearchProduct() when searchProduct != null:
        return searchProduct(_that.query);
      case _FetchAllFromState() when fetchAllFromState != null:
        return fetchAllFromState();
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Started implements ProductEvent {
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
    return 'ProductEvent.started()';
  }
}

/// @nodoc

class _Fetch implements ProductEvent {
  const _Fetch();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Fetch);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ProductEvent.fetch()';
  }
}

/// @nodoc

class _FetchByCategory implements ProductEvent {
  const _FetchByCategory(this.category);

  final String category;

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FetchByCategoryCopyWith<_FetchByCategory> get copyWith =>
      __$FetchByCategoryCopyWithImpl<_FetchByCategory>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FetchByCategory &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @override
  int get hashCode => Object.hash(runtimeType, category);

  @override
  String toString() {
    return 'ProductEvent.fetchByCategory(category: $category)';
  }
}

/// @nodoc
abstract mixin class _$FetchByCategoryCopyWith<$Res>
    implements $ProductEventCopyWith<$Res> {
  factory _$FetchByCategoryCopyWith(
          _FetchByCategory value, $Res Function(_FetchByCategory) _then) =
      __$FetchByCategoryCopyWithImpl;
  @useResult
  $Res call({String category});
}

/// @nodoc
class __$FetchByCategoryCopyWithImpl<$Res>
    implements _$FetchByCategoryCopyWith<$Res> {
  __$FetchByCategoryCopyWithImpl(this._self, this._then);

  final _FetchByCategory _self;
  final $Res Function(_FetchByCategory) _then;

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? category = null,
  }) {
    return _then(_FetchByCategory(
      null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _FetchLocal implements ProductEvent {
  const _FetchLocal();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _FetchLocal);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ProductEvent.fetchLocal()';
  }
}

/// @nodoc

class _AddProduct implements ProductEvent {
  const _AddProduct(this.product, this.image);

  final Product product;
  final XFile image;

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AddProductCopyWith<_AddProduct> get copyWith =>
      __$AddProductCopyWithImpl<_AddProduct>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AddProduct &&
            (identical(other.product, product) || other.product == product) &&
            (identical(other.image, image) || other.image == image));
  }

  @override
  int get hashCode => Object.hash(runtimeType, product, image);

  @override
  String toString() {
    return 'ProductEvent.addProduct(product: $product, image: $image)';
  }
}

/// @nodoc
abstract mixin class _$AddProductCopyWith<$Res>
    implements $ProductEventCopyWith<$Res> {
  factory _$AddProductCopyWith(
          _AddProduct value, $Res Function(_AddProduct) _then) =
      __$AddProductCopyWithImpl;
  @useResult
  $Res call({Product product, XFile image});
}

/// @nodoc
class __$AddProductCopyWithImpl<$Res> implements _$AddProductCopyWith<$Res> {
  __$AddProductCopyWithImpl(this._self, this._then);

  final _AddProduct _self;
  final $Res Function(_AddProduct) _then;

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? product = null,
    Object? image = null,
  }) {
    return _then(_AddProduct(
      null == product
          ? _self.product
          : product // ignore: cast_nullable_to_non_nullable
              as Product,
      null == image
          ? _self.image
          : image // ignore: cast_nullable_to_non_nullable
              as XFile,
    ));
  }
}

/// @nodoc

class _UpdateProduct implements ProductEvent {
  const _UpdateProduct(
      {required this.productId, required this.product, this.image});

  final int productId;
  final Product product;
  final XFile? image;

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UpdateProductCopyWith<_UpdateProduct> get copyWith =>
      __$UpdateProductCopyWithImpl<_UpdateProduct>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UpdateProduct &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.product, product) || other.product == product) &&
            (identical(other.image, image) || other.image == image));
  }

  @override
  int get hashCode => Object.hash(runtimeType, productId, product, image);

  @override
  String toString() {
    return 'ProductEvent.updateProduct(productId: $productId, product: $product, image: $image)';
  }
}

/// @nodoc
abstract mixin class _$UpdateProductCopyWith<$Res>
    implements $ProductEventCopyWith<$Res> {
  factory _$UpdateProductCopyWith(
          _UpdateProduct value, $Res Function(_UpdateProduct) _then) =
      __$UpdateProductCopyWithImpl;
  @useResult
  $Res call({int productId, Product product, XFile? image});
}

/// @nodoc
class __$UpdateProductCopyWithImpl<$Res>
    implements _$UpdateProductCopyWith<$Res> {
  __$UpdateProductCopyWithImpl(this._self, this._then);

  final _UpdateProduct _self;
  final $Res Function(_UpdateProduct) _then;

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? productId = null,
    Object? product = null,
    Object? image = freezed,
  }) {
    return _then(_UpdateProduct(
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as int,
      product: null == product
          ? _self.product
          : product // ignore: cast_nullable_to_non_nullable
              as Product,
      image: freezed == image
          ? _self.image
          : image // ignore: cast_nullable_to_non_nullable
              as XFile?,
    ));
  }
}

/// @nodoc

class _SearchProduct implements ProductEvent {
  const _SearchProduct(this.query);

  final String query;

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SearchProductCopyWith<_SearchProduct> get copyWith =>
      __$SearchProductCopyWithImpl<_SearchProduct>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SearchProduct &&
            (identical(other.query, query) || other.query == query));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query);

  @override
  String toString() {
    return 'ProductEvent.searchProduct(query: $query)';
  }
}

/// @nodoc
abstract mixin class _$SearchProductCopyWith<$Res>
    implements $ProductEventCopyWith<$Res> {
  factory _$SearchProductCopyWith(
          _SearchProduct value, $Res Function(_SearchProduct) _then) =
      __$SearchProductCopyWithImpl;
  @useResult
  $Res call({String query});
}

/// @nodoc
class __$SearchProductCopyWithImpl<$Res>
    implements _$SearchProductCopyWith<$Res> {
  __$SearchProductCopyWithImpl(this._self, this._then);

  final _SearchProduct _self;
  final $Res Function(_SearchProduct) _then;

  /// Create a copy of ProductEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? query = null,
  }) {
    return _then(_SearchProduct(
      null == query
          ? _self.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _FetchAllFromState implements ProductEvent {
  const _FetchAllFromState();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _FetchAllFromState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ProductEvent.fetchAllFromState()';
  }
}

/// @nodoc
mixin _$ProductState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ProductState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ProductState()';
  }
}

/// @nodoc
class $ProductStateCopyWith<$Res> {
  $ProductStateCopyWith(ProductState _, $Res Function(ProductState) __);
}

/// Adds pattern-matching-related methods to [ProductState].
extension ProductStatePatterns on ProductState {
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
    TResult Function(List<Product> products)? success,
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
        return success(_that.products);
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
    required TResult Function(List<Product> products) success,
    required TResult Function(String message) error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial();
      case _Loading():
        return loading();
      case _Success():
        return success(_that.products);
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
    TResult? Function(List<Product> products)? success,
    TResult? Function(String message)? error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Loading() when loading != null:
        return loading();
      case _Success() when success != null:
        return success(_that.products);
      case _Error() when error != null:
        return error(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Initial implements ProductState {
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
    return 'ProductState.initial()';
  }
}

/// @nodoc

class _Loading implements ProductState {
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
    return 'ProductState.loading()';
  }
}

/// @nodoc

class _Success implements ProductState {
  const _Success(final List<Product> products) : _products = products;

  final List<Product> _products;
  List<Product> get products {
    if (_products is EqualUnmodifiableListView) return _products;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_products);
  }

  /// Create a copy of ProductState
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
            const DeepCollectionEquality().equals(other._products, _products));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_products));

  @override
  String toString() {
    return 'ProductState.success(products: $products)';
  }
}

/// @nodoc
abstract mixin class _$SuccessCopyWith<$Res>
    implements $ProductStateCopyWith<$Res> {
  factory _$SuccessCopyWith(_Success value, $Res Function(_Success) _then) =
      __$SuccessCopyWithImpl;
  @useResult
  $Res call({List<Product> products});
}

/// @nodoc
class __$SuccessCopyWithImpl<$Res> implements _$SuccessCopyWith<$Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success _self;
  final $Res Function(_Success) _then;

  /// Create a copy of ProductState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? products = null,
  }) {
    return _then(_Success(
      null == products
          ? _self._products
          : products // ignore: cast_nullable_to_non_nullable
              as List<Product>,
    ));
  }
}

/// @nodoc

class _Error implements ProductState {
  const _Error(this.message);

  final String message;

  /// Create a copy of ProductState
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
    return 'ProductState.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res>
    implements $ProductStateCopyWith<$Res> {
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

  /// Create a copy of ProductState
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
