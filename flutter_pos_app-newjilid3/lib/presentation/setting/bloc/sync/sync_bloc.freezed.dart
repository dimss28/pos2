// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncEvent implements DiagnosticableTreeMixin {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'SyncEvent'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SyncEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SyncEvent()';
  }
}

/// @nodoc
class $SyncEventCopyWith<$Res> {
  $SyncEventCopyWith(SyncEvent _, $Res Function(SyncEvent) __);
}

/// Adds pattern-matching-related methods to [SyncEvent].
extension SyncEventPatterns on SyncEvent {
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
    TResult Function(_Bootstrap value)? bootstrap,
    TResult Function(_SyncAll value)? syncAll,
    TResult Function(_PullProducts value)? pullProducts,
    TResult Function(_PullCategories value)? pullCategories,
    TResult Function(_PullPromos value)? pullPromos,
    TResult Function(_PushOrders value)? pushOrders,
    TResult Function(_RefreshSnapshot value)? refreshSnapshot,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Bootstrap() when bootstrap != null:
        return bootstrap(_that);
      case _SyncAll() when syncAll != null:
        return syncAll(_that);
      case _PullProducts() when pullProducts != null:
        return pullProducts(_that);
      case _PullCategories() when pullCategories != null:
        return pullCategories(_that);
      case _PullPromos() when pullPromos != null:
        return pullPromos(_that);
      case _PushOrders() when pushOrders != null:
        return pushOrders(_that);
      case _RefreshSnapshot() when refreshSnapshot != null:
        return refreshSnapshot(_that);
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
    required TResult Function(_Bootstrap value) bootstrap,
    required TResult Function(_SyncAll value) syncAll,
    required TResult Function(_PullProducts value) pullProducts,
    required TResult Function(_PullCategories value) pullCategories,
    required TResult Function(_PullPromos value) pullPromos,
    required TResult Function(_PushOrders value) pushOrders,
    required TResult Function(_RefreshSnapshot value) refreshSnapshot,
  }) {
    final _that = this;
    switch (_that) {
      case _Bootstrap():
        return bootstrap(_that);
      case _SyncAll():
        return syncAll(_that);
      case _PullProducts():
        return pullProducts(_that);
      case _PullCategories():
        return pullCategories(_that);
      case _PullPromos():
        return pullPromos(_that);
      case _PushOrders():
        return pushOrders(_that);
      case _RefreshSnapshot():
        return refreshSnapshot(_that);
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
    TResult? Function(_Bootstrap value)? bootstrap,
    TResult? Function(_SyncAll value)? syncAll,
    TResult? Function(_PullProducts value)? pullProducts,
    TResult? Function(_PullCategories value)? pullCategories,
    TResult? Function(_PullPromos value)? pullPromos,
    TResult? Function(_PushOrders value)? pushOrders,
    TResult? Function(_RefreshSnapshot value)? refreshSnapshot,
  }) {
    final _that = this;
    switch (_that) {
      case _Bootstrap() when bootstrap != null:
        return bootstrap(_that);
      case _SyncAll() when syncAll != null:
        return syncAll(_that);
      case _PullProducts() when pullProducts != null:
        return pullProducts(_that);
      case _PullCategories() when pullCategories != null:
        return pullCategories(_that);
      case _PullPromos() when pullPromos != null:
        return pullPromos(_that);
      case _PushOrders() when pushOrders != null:
        return pushOrders(_that);
      case _RefreshSnapshot() when refreshSnapshot != null:
        return refreshSnapshot(_that);
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
    TResult Function()? bootstrap,
    TResult Function()? syncAll,
    TResult Function()? pullProducts,
    TResult Function()? pullCategories,
    TResult Function()? pullPromos,
    TResult Function()? pushOrders,
    TResult Function()? refreshSnapshot,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Bootstrap() when bootstrap != null:
        return bootstrap();
      case _SyncAll() when syncAll != null:
        return syncAll();
      case _PullProducts() when pullProducts != null:
        return pullProducts();
      case _PullCategories() when pullCategories != null:
        return pullCategories();
      case _PullPromos() when pullPromos != null:
        return pullPromos();
      case _PushOrders() when pushOrders != null:
        return pushOrders();
      case _RefreshSnapshot() when refreshSnapshot != null:
        return refreshSnapshot();
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
    required TResult Function() bootstrap,
    required TResult Function() syncAll,
    required TResult Function() pullProducts,
    required TResult Function() pullCategories,
    required TResult Function() pullPromos,
    required TResult Function() pushOrders,
    required TResult Function() refreshSnapshot,
  }) {
    final _that = this;
    switch (_that) {
      case _Bootstrap():
        return bootstrap();
      case _SyncAll():
        return syncAll();
      case _PullProducts():
        return pullProducts();
      case _PullCategories():
        return pullCategories();
      case _PullPromos():
        return pullPromos();
      case _PushOrders():
        return pushOrders();
      case _RefreshSnapshot():
        return refreshSnapshot();
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
    TResult? Function()? bootstrap,
    TResult? Function()? syncAll,
    TResult? Function()? pullProducts,
    TResult? Function()? pullCategories,
    TResult? Function()? pullPromos,
    TResult? Function()? pushOrders,
    TResult? Function()? refreshSnapshot,
  }) {
    final _that = this;
    switch (_that) {
      case _Bootstrap() when bootstrap != null:
        return bootstrap();
      case _SyncAll() when syncAll != null:
        return syncAll();
      case _PullProducts() when pullProducts != null:
        return pullProducts();
      case _PullCategories() when pullCategories != null:
        return pullCategories();
      case _PullPromos() when pullPromos != null:
        return pullPromos();
      case _PushOrders() when pushOrders != null:
        return pushOrders();
      case _RefreshSnapshot() when refreshSnapshot != null:
        return refreshSnapshot();
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Bootstrap with DiagnosticableTreeMixin implements SyncEvent {
  const _Bootstrap();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'SyncEvent.bootstrap'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Bootstrap);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SyncEvent.bootstrap()';
  }
}

/// @nodoc

class _SyncAll with DiagnosticableTreeMixin implements SyncEvent {
  const _SyncAll();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'SyncEvent.syncAll'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _SyncAll);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SyncEvent.syncAll()';
  }
}

/// @nodoc

class _PullProducts with DiagnosticableTreeMixin implements SyncEvent {
  const _PullProducts();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'SyncEvent.pullProducts'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _PullProducts);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SyncEvent.pullProducts()';
  }
}

/// @nodoc

class _PullCategories with DiagnosticableTreeMixin implements SyncEvent {
  const _PullCategories();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'SyncEvent.pullCategories'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _PullCategories);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SyncEvent.pullCategories()';
  }
}

/// @nodoc

class _PullPromos with DiagnosticableTreeMixin implements SyncEvent {
  const _PullPromos();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'SyncEvent.pullPromos'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _PullPromos);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SyncEvent.pullPromos()';
  }
}

/// @nodoc

class _PushOrders with DiagnosticableTreeMixin implements SyncEvent {
  const _PushOrders();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'SyncEvent.pushOrders'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _PushOrders);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SyncEvent.pushOrders()';
  }
}

/// @nodoc

class _RefreshSnapshot with DiagnosticableTreeMixin implements SyncEvent {
  const _RefreshSnapshot();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'SyncEvent.refreshSnapshot'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _RefreshSnapshot);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SyncEvent.refreshSnapshot()';
  }
}

/// @nodoc
mixin _$SyncSnapshot implements DiagnosticableTreeMixin {
  int get productCount;
  int get categoryCount;
  int get promoCount;
  int get pendingOrderCount;
  DateTime? get lastSyncProductsAt;
  DateTime? get lastSyncCategoriesAt;
  DateTime? get lastSyncPromosAt;
  DateTime? get lastSyncOrdersAt;

  /// Non-null while a sync is in flight. Value is the domain key:
  /// `'products' | 'categories' | 'promos' | 'orders'`.
  String? get inProgress;

  /// Last error per domain. Empty map = everything clean.
  Map<String, String> get errors;

  /// Create a copy of SyncSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SyncSnapshotCopyWith<SyncSnapshot> get copyWith =>
      _$SyncSnapshotCopyWithImpl<SyncSnapshot>(
          this as SyncSnapshot, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SyncSnapshot'))
      ..add(DiagnosticsProperty('productCount', productCount))
      ..add(DiagnosticsProperty('categoryCount', categoryCount))
      ..add(DiagnosticsProperty('promoCount', promoCount))
      ..add(DiagnosticsProperty('pendingOrderCount', pendingOrderCount))
      ..add(DiagnosticsProperty('lastSyncProductsAt', lastSyncProductsAt))
      ..add(DiagnosticsProperty('lastSyncCategoriesAt', lastSyncCategoriesAt))
      ..add(DiagnosticsProperty('lastSyncPromosAt', lastSyncPromosAt))
      ..add(DiagnosticsProperty('lastSyncOrdersAt', lastSyncOrdersAt))
      ..add(DiagnosticsProperty('inProgress', inProgress))
      ..add(DiagnosticsProperty('errors', errors));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SyncSnapshot &&
            (identical(other.productCount, productCount) ||
                other.productCount == productCount) &&
            (identical(other.categoryCount, categoryCount) ||
                other.categoryCount == categoryCount) &&
            (identical(other.promoCount, promoCount) ||
                other.promoCount == promoCount) &&
            (identical(other.pendingOrderCount, pendingOrderCount) ||
                other.pendingOrderCount == pendingOrderCount) &&
            (identical(other.lastSyncProductsAt, lastSyncProductsAt) ||
                other.lastSyncProductsAt == lastSyncProductsAt) &&
            (identical(other.lastSyncCategoriesAt, lastSyncCategoriesAt) ||
                other.lastSyncCategoriesAt == lastSyncCategoriesAt) &&
            (identical(other.lastSyncPromosAt, lastSyncPromosAt) ||
                other.lastSyncPromosAt == lastSyncPromosAt) &&
            (identical(other.lastSyncOrdersAt, lastSyncOrdersAt) ||
                other.lastSyncOrdersAt == lastSyncOrdersAt) &&
            (identical(other.inProgress, inProgress) ||
                other.inProgress == inProgress) &&
            const DeepCollectionEquality().equals(other.errors, errors));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      productCount,
      categoryCount,
      promoCount,
      pendingOrderCount,
      lastSyncProductsAt,
      lastSyncCategoriesAt,
      lastSyncPromosAt,
      lastSyncOrdersAt,
      inProgress,
      const DeepCollectionEquality().hash(errors));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SyncSnapshot(productCount: $productCount, categoryCount: $categoryCount, promoCount: $promoCount, pendingOrderCount: $pendingOrderCount, lastSyncProductsAt: $lastSyncProductsAt, lastSyncCategoriesAt: $lastSyncCategoriesAt, lastSyncPromosAt: $lastSyncPromosAt, lastSyncOrdersAt: $lastSyncOrdersAt, inProgress: $inProgress, errors: $errors)';
  }
}

/// @nodoc
abstract mixin class $SyncSnapshotCopyWith<$Res> {
  factory $SyncSnapshotCopyWith(
          SyncSnapshot value, $Res Function(SyncSnapshot) _then) =
      _$SyncSnapshotCopyWithImpl;
  @useResult
  $Res call(
      {int productCount,
      int categoryCount,
      int promoCount,
      int pendingOrderCount,
      DateTime? lastSyncProductsAt,
      DateTime? lastSyncCategoriesAt,
      DateTime? lastSyncPromosAt,
      DateTime? lastSyncOrdersAt,
      String? inProgress,
      Map<String, String> errors});
}

/// @nodoc
class _$SyncSnapshotCopyWithImpl<$Res> implements $SyncSnapshotCopyWith<$Res> {
  _$SyncSnapshotCopyWithImpl(this._self, this._then);

  final SyncSnapshot _self;
  final $Res Function(SyncSnapshot) _then;

  /// Create a copy of SyncSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productCount = null,
    Object? categoryCount = null,
    Object? promoCount = null,
    Object? pendingOrderCount = null,
    Object? lastSyncProductsAt = freezed,
    Object? lastSyncCategoriesAt = freezed,
    Object? lastSyncPromosAt = freezed,
    Object? lastSyncOrdersAt = freezed,
    Object? inProgress = freezed,
    Object? errors = null,
  }) {
    return _then(_self.copyWith(
      productCount: null == productCount
          ? _self.productCount
          : productCount // ignore: cast_nullable_to_non_nullable
              as int,
      categoryCount: null == categoryCount
          ? _self.categoryCount
          : categoryCount // ignore: cast_nullable_to_non_nullable
              as int,
      promoCount: null == promoCount
          ? _self.promoCount
          : promoCount // ignore: cast_nullable_to_non_nullable
              as int,
      pendingOrderCount: null == pendingOrderCount
          ? _self.pendingOrderCount
          : pendingOrderCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastSyncProductsAt: freezed == lastSyncProductsAt
          ? _self.lastSyncProductsAt
          : lastSyncProductsAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSyncCategoriesAt: freezed == lastSyncCategoriesAt
          ? _self.lastSyncCategoriesAt
          : lastSyncCategoriesAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSyncPromosAt: freezed == lastSyncPromosAt
          ? _self.lastSyncPromosAt
          : lastSyncPromosAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSyncOrdersAt: freezed == lastSyncOrdersAt
          ? _self.lastSyncOrdersAt
          : lastSyncOrdersAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      inProgress: freezed == inProgress
          ? _self.inProgress
          : inProgress // ignore: cast_nullable_to_non_nullable
              as String?,
      errors: null == errors
          ? _self.errors
          : errors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [SyncSnapshot].
extension SyncSnapshotPatterns on SyncSnapshot {
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
    TResult Function(_SyncSnapshot value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SyncSnapshot() when $default != null:
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
    TResult Function(_SyncSnapshot value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SyncSnapshot():
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
    TResult? Function(_SyncSnapshot value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SyncSnapshot() when $default != null:
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
            int productCount,
            int categoryCount,
            int promoCount,
            int pendingOrderCount,
            DateTime? lastSyncProductsAt,
            DateTime? lastSyncCategoriesAt,
            DateTime? lastSyncPromosAt,
            DateTime? lastSyncOrdersAt,
            String? inProgress,
            Map<String, String> errors)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SyncSnapshot() when $default != null:
        return $default(
            _that.productCount,
            _that.categoryCount,
            _that.promoCount,
            _that.pendingOrderCount,
            _that.lastSyncProductsAt,
            _that.lastSyncCategoriesAt,
            _that.lastSyncPromosAt,
            _that.lastSyncOrdersAt,
            _that.inProgress,
            _that.errors);
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
            int productCount,
            int categoryCount,
            int promoCount,
            int pendingOrderCount,
            DateTime? lastSyncProductsAt,
            DateTime? lastSyncCategoriesAt,
            DateTime? lastSyncPromosAt,
            DateTime? lastSyncOrdersAt,
            String? inProgress,
            Map<String, String> errors)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SyncSnapshot():
        return $default(
            _that.productCount,
            _that.categoryCount,
            _that.promoCount,
            _that.pendingOrderCount,
            _that.lastSyncProductsAt,
            _that.lastSyncCategoriesAt,
            _that.lastSyncPromosAt,
            _that.lastSyncOrdersAt,
            _that.inProgress,
            _that.errors);
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
            int productCount,
            int categoryCount,
            int promoCount,
            int pendingOrderCount,
            DateTime? lastSyncProductsAt,
            DateTime? lastSyncCategoriesAt,
            DateTime? lastSyncPromosAt,
            DateTime? lastSyncOrdersAt,
            String? inProgress,
            Map<String, String> errors)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SyncSnapshot() when $default != null:
        return $default(
            _that.productCount,
            _that.categoryCount,
            _that.promoCount,
            _that.pendingOrderCount,
            _that.lastSyncProductsAt,
            _that.lastSyncCategoriesAt,
            _that.lastSyncPromosAt,
            _that.lastSyncOrdersAt,
            _that.inProgress,
            _that.errors);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SyncSnapshot with DiagnosticableTreeMixin implements SyncSnapshot {
  const _SyncSnapshot(
      {this.productCount = 0,
      this.categoryCount = 0,
      this.promoCount = 0,
      this.pendingOrderCount = 0,
      this.lastSyncProductsAt,
      this.lastSyncCategoriesAt,
      this.lastSyncPromosAt,
      this.lastSyncOrdersAt,
      this.inProgress,
      final Map<String, String> errors = const <String, String>{}})
      : _errors = errors;

  @override
  @JsonKey()
  final int productCount;
  @override
  @JsonKey()
  final int categoryCount;
  @override
  @JsonKey()
  final int promoCount;
  @override
  @JsonKey()
  final int pendingOrderCount;
  @override
  final DateTime? lastSyncProductsAt;
  @override
  final DateTime? lastSyncCategoriesAt;
  @override
  final DateTime? lastSyncPromosAt;
  @override
  final DateTime? lastSyncOrdersAt;

  /// Non-null while a sync is in flight. Value is the domain key:
  /// `'products' | 'categories' | 'promos' | 'orders'`.
  @override
  final String? inProgress;

  /// Last error per domain. Empty map = everything clean.
  final Map<String, String> _errors;

  /// Last error per domain. Empty map = everything clean.
  @override
  @JsonKey()
  Map<String, String> get errors {
    if (_errors is EqualUnmodifiableMapView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_errors);
  }

  /// Create a copy of SyncSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SyncSnapshotCopyWith<_SyncSnapshot> get copyWith =>
      __$SyncSnapshotCopyWithImpl<_SyncSnapshot>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SyncSnapshot'))
      ..add(DiagnosticsProperty('productCount', productCount))
      ..add(DiagnosticsProperty('categoryCount', categoryCount))
      ..add(DiagnosticsProperty('promoCount', promoCount))
      ..add(DiagnosticsProperty('pendingOrderCount', pendingOrderCount))
      ..add(DiagnosticsProperty('lastSyncProductsAt', lastSyncProductsAt))
      ..add(DiagnosticsProperty('lastSyncCategoriesAt', lastSyncCategoriesAt))
      ..add(DiagnosticsProperty('lastSyncPromosAt', lastSyncPromosAt))
      ..add(DiagnosticsProperty('lastSyncOrdersAt', lastSyncOrdersAt))
      ..add(DiagnosticsProperty('inProgress', inProgress))
      ..add(DiagnosticsProperty('errors', errors));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SyncSnapshot &&
            (identical(other.productCount, productCount) ||
                other.productCount == productCount) &&
            (identical(other.categoryCount, categoryCount) ||
                other.categoryCount == categoryCount) &&
            (identical(other.promoCount, promoCount) ||
                other.promoCount == promoCount) &&
            (identical(other.pendingOrderCount, pendingOrderCount) ||
                other.pendingOrderCount == pendingOrderCount) &&
            (identical(other.lastSyncProductsAt, lastSyncProductsAt) ||
                other.lastSyncProductsAt == lastSyncProductsAt) &&
            (identical(other.lastSyncCategoriesAt, lastSyncCategoriesAt) ||
                other.lastSyncCategoriesAt == lastSyncCategoriesAt) &&
            (identical(other.lastSyncPromosAt, lastSyncPromosAt) ||
                other.lastSyncPromosAt == lastSyncPromosAt) &&
            (identical(other.lastSyncOrdersAt, lastSyncOrdersAt) ||
                other.lastSyncOrdersAt == lastSyncOrdersAt) &&
            (identical(other.inProgress, inProgress) ||
                other.inProgress == inProgress) &&
            const DeepCollectionEquality().equals(other._errors, _errors));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      productCount,
      categoryCount,
      promoCount,
      pendingOrderCount,
      lastSyncProductsAt,
      lastSyncCategoriesAt,
      lastSyncPromosAt,
      lastSyncOrdersAt,
      inProgress,
      const DeepCollectionEquality().hash(_errors));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SyncSnapshot(productCount: $productCount, categoryCount: $categoryCount, promoCount: $promoCount, pendingOrderCount: $pendingOrderCount, lastSyncProductsAt: $lastSyncProductsAt, lastSyncCategoriesAt: $lastSyncCategoriesAt, lastSyncPromosAt: $lastSyncPromosAt, lastSyncOrdersAt: $lastSyncOrdersAt, inProgress: $inProgress, errors: $errors)';
  }
}

/// @nodoc
abstract mixin class _$SyncSnapshotCopyWith<$Res>
    implements $SyncSnapshotCopyWith<$Res> {
  factory _$SyncSnapshotCopyWith(
          _SyncSnapshot value, $Res Function(_SyncSnapshot) _then) =
      __$SyncSnapshotCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int productCount,
      int categoryCount,
      int promoCount,
      int pendingOrderCount,
      DateTime? lastSyncProductsAt,
      DateTime? lastSyncCategoriesAt,
      DateTime? lastSyncPromosAt,
      DateTime? lastSyncOrdersAt,
      String? inProgress,
      Map<String, String> errors});
}

/// @nodoc
class __$SyncSnapshotCopyWithImpl<$Res>
    implements _$SyncSnapshotCopyWith<$Res> {
  __$SyncSnapshotCopyWithImpl(this._self, this._then);

  final _SyncSnapshot _self;
  final $Res Function(_SyncSnapshot) _then;

  /// Create a copy of SyncSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? productCount = null,
    Object? categoryCount = null,
    Object? promoCount = null,
    Object? pendingOrderCount = null,
    Object? lastSyncProductsAt = freezed,
    Object? lastSyncCategoriesAt = freezed,
    Object? lastSyncPromosAt = freezed,
    Object? lastSyncOrdersAt = freezed,
    Object? inProgress = freezed,
    Object? errors = null,
  }) {
    return _then(_SyncSnapshot(
      productCount: null == productCount
          ? _self.productCount
          : productCount // ignore: cast_nullable_to_non_nullable
              as int,
      categoryCount: null == categoryCount
          ? _self.categoryCount
          : categoryCount // ignore: cast_nullable_to_non_nullable
              as int,
      promoCount: null == promoCount
          ? _self.promoCount
          : promoCount // ignore: cast_nullable_to_non_nullable
              as int,
      pendingOrderCount: null == pendingOrderCount
          ? _self.pendingOrderCount
          : pendingOrderCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastSyncProductsAt: freezed == lastSyncProductsAt
          ? _self.lastSyncProductsAt
          : lastSyncProductsAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSyncCategoriesAt: freezed == lastSyncCategoriesAt
          ? _self.lastSyncCategoriesAt
          : lastSyncCategoriesAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSyncPromosAt: freezed == lastSyncPromosAt
          ? _self.lastSyncPromosAt
          : lastSyncPromosAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSyncOrdersAt: freezed == lastSyncOrdersAt
          ? _self.lastSyncOrdersAt
          : lastSyncOrdersAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      inProgress: freezed == inProgress
          ? _self.inProgress
          : inProgress // ignore: cast_nullable_to_non_nullable
              as String?,
      errors: null == errors
          ? _self._errors
          : errors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

/// @nodoc
mixin _$SyncState implements DiagnosticableTreeMixin {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'SyncState'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SyncState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SyncState()';
  }
}

/// @nodoc
class $SyncStateCopyWith<$Res> {
  $SyncStateCopyWith(SyncState _, $Res Function(SyncState) __);
}

/// Adds pattern-matching-related methods to [SyncState].
extension SyncStatePatterns on SyncState {
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
    TResult Function(_Ready value)? ready,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case _Ready() when ready != null:
        return ready(_that);
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
    required TResult Function(_Ready value) ready,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial(_that);
      case _Ready():
        return ready(_that);
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
    TResult? Function(_Ready value)? ready,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case _Ready() when ready != null:
        return ready(_that);
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
    TResult Function(SyncSnapshot snapshot)? ready,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Ready() when ready != null:
        return ready(_that.snapshot);
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
    required TResult Function(SyncSnapshot snapshot) ready,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial();
      case _Ready():
        return ready(_that.snapshot);
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
    TResult? Function(SyncSnapshot snapshot)? ready,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Ready() when ready != null:
        return ready(_that.snapshot);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Initial with DiagnosticableTreeMixin implements SyncState {
  const _Initial();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'SyncState.initial'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Initial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SyncState.initial()';
  }
}

/// @nodoc

class _Ready with DiagnosticableTreeMixin implements SyncState {
  const _Ready(this.snapshot);

  final SyncSnapshot snapshot;

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReadyCopyWith<_Ready> get copyWith =>
      __$ReadyCopyWithImpl<_Ready>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SyncState.ready'))
      ..add(DiagnosticsProperty('snapshot', snapshot));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Ready &&
            (identical(other.snapshot, snapshot) ||
                other.snapshot == snapshot));
  }

  @override
  int get hashCode => Object.hash(runtimeType, snapshot);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SyncState.ready(snapshot: $snapshot)';
  }
}

/// @nodoc
abstract mixin class _$ReadyCopyWith<$Res> implements $SyncStateCopyWith<$Res> {
  factory _$ReadyCopyWith(_Ready value, $Res Function(_Ready) _then) =
      __$ReadyCopyWithImpl;
  @useResult
  $Res call({SyncSnapshot snapshot});

  $SyncSnapshotCopyWith<$Res> get snapshot;
}

/// @nodoc
class __$ReadyCopyWithImpl<$Res> implements _$ReadyCopyWith<$Res> {
  __$ReadyCopyWithImpl(this._self, this._then);

  final _Ready _self;
  final $Res Function(_Ready) _then;

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? snapshot = null,
  }) {
    return _then(_Ready(
      null == snapshot
          ? _self.snapshot
          : snapshot // ignore: cast_nullable_to_non_nullable
              as SyncSnapshot,
    ));
  }

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SyncSnapshotCopyWith<$Res> get snapshot {
    return $SyncSnapshotCopyWith<$Res>(_self.snapshot, (value) {
      return _then(_self.copyWith(snapshot: value));
    });
  }
}

// dart format on
