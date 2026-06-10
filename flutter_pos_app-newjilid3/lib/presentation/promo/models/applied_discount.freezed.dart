// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'applied_discount.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppliedDiscount {
  int get amount;
  PromoModel? get promo;
  AppliedDiscountSource get source;
  String? get note;

  /// Create a copy of AppliedDiscount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AppliedDiscountCopyWith<AppliedDiscount> get copyWith =>
      _$AppliedDiscountCopyWithImpl<AppliedDiscount>(
          this as AppliedDiscount, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppliedDiscount &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.promo, promo) || other.promo == promo) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.note, note) || other.note == note));
  }

  @override
  int get hashCode => Object.hash(runtimeType, amount, promo, source, note);

  @override
  String toString() {
    return 'AppliedDiscount(amount: $amount, promo: $promo, source: $source, note: $note)';
  }
}

/// @nodoc
abstract mixin class $AppliedDiscountCopyWith<$Res> {
  factory $AppliedDiscountCopyWith(
          AppliedDiscount value, $Res Function(AppliedDiscount) _then) =
      _$AppliedDiscountCopyWithImpl;
  @useResult
  $Res call(
      {int amount,
      PromoModel? promo,
      AppliedDiscountSource source,
      String? note});
}

/// @nodoc
class _$AppliedDiscountCopyWithImpl<$Res>
    implements $AppliedDiscountCopyWith<$Res> {
  _$AppliedDiscountCopyWithImpl(this._self, this._then);

  final AppliedDiscount _self;
  final $Res Function(AppliedDiscount) _then;

  /// Create a copy of AppliedDiscount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? promo = freezed,
    Object? source = null,
    Object? note = freezed,
  }) {
    return _then(_self.copyWith(
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      promo: freezed == promo
          ? _self.promo
          : promo // ignore: cast_nullable_to_non_nullable
              as PromoModel?,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as AppliedDiscountSource,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AppliedDiscount].
extension AppliedDiscountPatterns on AppliedDiscount {
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
    TResult Function(_AppliedDiscount value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AppliedDiscount() when $default != null:
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
    TResult Function(_AppliedDiscount value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppliedDiscount():
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
    TResult? Function(_AppliedDiscount value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppliedDiscount() when $default != null:
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
    TResult Function(int amount, PromoModel? promo,
            AppliedDiscountSource source, String? note)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AppliedDiscount() when $default != null:
        return $default(_that.amount, _that.promo, _that.source, _that.note);
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
    TResult Function(int amount, PromoModel? promo,
            AppliedDiscountSource source, String? note)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppliedDiscount():
        return $default(_that.amount, _that.promo, _that.source, _that.note);
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
    TResult? Function(int amount, PromoModel? promo,
            AppliedDiscountSource source, String? note)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppliedDiscount() when $default != null:
        return $default(_that.amount, _that.promo, _that.source, _that.note);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AppliedDiscount extends AppliedDiscount {
  const _AppliedDiscount(
      {required this.amount,
      this.promo,
      this.source = AppliedDiscountSource.manual,
      this.note})
      : super._();

  @override
  final int amount;
  @override
  final PromoModel? promo;
  @override
  @JsonKey()
  final AppliedDiscountSource source;
  @override
  final String? note;

  /// Create a copy of AppliedDiscount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AppliedDiscountCopyWith<_AppliedDiscount> get copyWith =>
      __$AppliedDiscountCopyWithImpl<_AppliedDiscount>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AppliedDiscount &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.promo, promo) || other.promo == promo) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.note, note) || other.note == note));
  }

  @override
  int get hashCode => Object.hash(runtimeType, amount, promo, source, note);

  @override
  String toString() {
    return 'AppliedDiscount(amount: $amount, promo: $promo, source: $source, note: $note)';
  }
}

/// @nodoc
abstract mixin class _$AppliedDiscountCopyWith<$Res>
    implements $AppliedDiscountCopyWith<$Res> {
  factory _$AppliedDiscountCopyWith(
          _AppliedDiscount value, $Res Function(_AppliedDiscount) _then) =
      __$AppliedDiscountCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int amount,
      PromoModel? promo,
      AppliedDiscountSource source,
      String? note});
}

/// @nodoc
class __$AppliedDiscountCopyWithImpl<$Res>
    implements _$AppliedDiscountCopyWith<$Res> {
  __$AppliedDiscountCopyWithImpl(this._self, this._then);

  final _AppliedDiscount _self;
  final $Res Function(_AppliedDiscount) _then;

  /// Create a copy of AppliedDiscount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? amount = null,
    Object? promo = freezed,
    Object? source = null,
    Object? note = freezed,
  }) {
    return _then(_AppliedDiscount(
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      promo: freezed == promo
          ? _self.promo
          : promo // ignore: cast_nullable_to_non_nullable
              as PromoModel?,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as AppliedDiscountSource,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
