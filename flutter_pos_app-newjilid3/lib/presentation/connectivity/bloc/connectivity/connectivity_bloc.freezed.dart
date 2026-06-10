// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connectivity_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConnectivityEvent implements DiagnosticableTreeMixin {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'ConnectivityEvent'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ConnectivityEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ConnectivityEvent()';
  }
}

/// @nodoc
class $ConnectivityEventCopyWith<$Res> {
  $ConnectivityEventCopyWith(
      ConnectivityEvent _, $Res Function(ConnectivityEvent) __);
}

/// Adds pattern-matching-related methods to [ConnectivityEvent].
extension ConnectivityEventPatterns on ConnectivityEvent {
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
    TResult Function(_ResultChanged value)? resultChanged,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started(_that);
      case _ResultChanged() when resultChanged != null:
        return resultChanged(_that);
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
    required TResult Function(_ResultChanged value) resultChanged,
  }) {
    final _that = this;
    switch (_that) {
      case _Started():
        return started(_that);
      case _ResultChanged():
        return resultChanged(_that);
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
    TResult? Function(_ResultChanged value)? resultChanged,
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started(_that);
      case _ResultChanged() when resultChanged != null:
        return resultChanged(_that);
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
    TResult Function(List<ConnectivityResult> results)? resultChanged,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started();
      case _ResultChanged() when resultChanged != null:
        return resultChanged(_that.results);
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
    required TResult Function(List<ConnectivityResult> results) resultChanged,
  }) {
    final _that = this;
    switch (_that) {
      case _Started():
        return started();
      case _ResultChanged():
        return resultChanged(_that.results);
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
    TResult? Function(List<ConnectivityResult> results)? resultChanged,
  }) {
    final _that = this;
    switch (_that) {
      case _Started() when started != null:
        return started();
      case _ResultChanged() when resultChanged != null:
        return resultChanged(_that.results);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Started with DiagnosticableTreeMixin implements ConnectivityEvent {
  const _Started();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'ConnectivityEvent.started'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Started);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ConnectivityEvent.started()';
  }
}

/// @nodoc

class _ResultChanged with DiagnosticableTreeMixin implements ConnectivityEvent {
  const _ResultChanged(final List<ConnectivityResult> results)
      : _results = results;

  final List<ConnectivityResult> _results;
  List<ConnectivityResult> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  /// Create a copy of ConnectivityEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ResultChangedCopyWith<_ResultChanged> get copyWith =>
      __$ResultChangedCopyWithImpl<_ResultChanged>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ConnectivityEvent.resultChanged'))
      ..add(DiagnosticsProperty('results', results));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ResultChanged &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_results));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ConnectivityEvent.resultChanged(results: $results)';
  }
}

/// @nodoc
abstract mixin class _$ResultChangedCopyWith<$Res>
    implements $ConnectivityEventCopyWith<$Res> {
  factory _$ResultChangedCopyWith(
          _ResultChanged value, $Res Function(_ResultChanged) _then) =
      __$ResultChangedCopyWithImpl;
  @useResult
  $Res call({List<ConnectivityResult> results});
}

/// @nodoc
class __$ResultChangedCopyWithImpl<$Res>
    implements _$ResultChangedCopyWith<$Res> {
  __$ResultChangedCopyWithImpl(this._self, this._then);

  final _ResultChanged _self;
  final $Res Function(_ResultChanged) _then;

  /// Create a copy of ConnectivityEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? results = null,
  }) {
    return _then(_ResultChanged(
      null == results
          ? _self._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<ConnectivityResult>,
    ));
  }
}

/// @nodoc
mixin _$ConnectivityState implements DiagnosticableTreeMixin {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'ConnectivityState'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ConnectivityState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ConnectivityState()';
  }
}

/// @nodoc
class $ConnectivityStateCopyWith<$Res> {
  $ConnectivityStateCopyWith(
      ConnectivityState _, $Res Function(ConnectivityState) __);
}

/// Adds pattern-matching-related methods to [ConnectivityState].
extension ConnectivityStatePatterns on ConnectivityState {
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
    TResult Function(_Unknown value)? unknown,
    TResult Function(_Online value)? online,
    TResult Function(_Offline value)? offline,
    TResult Function(_Restored value)? restored,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Unknown() when unknown != null:
        return unknown(_that);
      case _Online() when online != null:
        return online(_that);
      case _Offline() when offline != null:
        return offline(_that);
      case _Restored() when restored != null:
        return restored(_that);
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
    required TResult Function(_Unknown value) unknown,
    required TResult Function(_Online value) online,
    required TResult Function(_Offline value) offline,
    required TResult Function(_Restored value) restored,
  }) {
    final _that = this;
    switch (_that) {
      case _Unknown():
        return unknown(_that);
      case _Online():
        return online(_that);
      case _Offline():
        return offline(_that);
      case _Restored():
        return restored(_that);
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
    TResult? Function(_Unknown value)? unknown,
    TResult? Function(_Online value)? online,
    TResult? Function(_Offline value)? offline,
    TResult? Function(_Restored value)? restored,
  }) {
    final _that = this;
    switch (_that) {
      case _Unknown() when unknown != null:
        return unknown(_that);
      case _Online() when online != null:
        return online(_that);
      case _Offline() when offline != null:
        return offline(_that);
      case _Restored() when restored != null:
        return restored(_that);
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
    TResult Function()? unknown,
    TResult Function()? online,
    TResult Function()? offline,
    TResult Function()? restored,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Unknown() when unknown != null:
        return unknown();
      case _Online() when online != null:
        return online();
      case _Offline() when offline != null:
        return offline();
      case _Restored() when restored != null:
        return restored();
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
    required TResult Function() unknown,
    required TResult Function() online,
    required TResult Function() offline,
    required TResult Function() restored,
  }) {
    final _that = this;
    switch (_that) {
      case _Unknown():
        return unknown();
      case _Online():
        return online();
      case _Offline():
        return offline();
      case _Restored():
        return restored();
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
    TResult? Function()? unknown,
    TResult? Function()? online,
    TResult? Function()? offline,
    TResult? Function()? restored,
  }) {
    final _that = this;
    switch (_that) {
      case _Unknown() when unknown != null:
        return unknown();
      case _Online() when online != null:
        return online();
      case _Offline() when offline != null:
        return offline();
      case _Restored() when restored != null:
        return restored();
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Unknown with DiagnosticableTreeMixin implements ConnectivityState {
  const _Unknown();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'ConnectivityState.unknown'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Unknown);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ConnectivityState.unknown()';
  }
}

/// @nodoc

class _Online with DiagnosticableTreeMixin implements ConnectivityState {
  const _Online();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'ConnectivityState.online'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Online);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ConnectivityState.online()';
  }
}

/// @nodoc

class _Offline with DiagnosticableTreeMixin implements ConnectivityState {
  const _Offline();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'ConnectivityState.offline'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Offline);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ConnectivityState.offline()';
  }
}

/// @nodoc

class _Restored with DiagnosticableTreeMixin implements ConnectivityState {
  const _Restored();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties..add(DiagnosticsProperty('type', 'ConnectivityState.restored'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Restored);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ConnectivityState.restored()';
  }
}

// dart format on
