// Version: 3.0.0

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reactive_forms/reactive_forms.dart';
// ignore: implementation_imports
import 'package:rivertion/src/internals.dart';

extension AbstractControlStateSource<V> on AbstractControl<V> {
  SourceListenable<AbstractControlState<V?>> get source => _AbstractControlStateSource(this);

  SourceListenable<R> select<R>(R Function(AbstractControl<V> control) selector) =>
      _FormControlSource(this).select(selector);
}

extension ControlStateSource<C extends AbstractControl<Object?>> on C {
  SourceListenable<R> select<R>(R Function(C control) selector) =>
      _FormControlSource(this).select(selector);
}

extension AbstractControlStateSourceExtensions<V> on SourceListenable<AbstractControlState<V>> {
  SourceListenable<bool> get hasValue => select(_hasValue);
  SourceListenable<V?> get value => select(_value);
  SourceListenable<bool> get pristine => select(_pristine);
  SourceListenable<bool> get dirty => select(_dirty);
  SourceListenable<bool> get touched => select(_touched);
  SourceListenable<ControlStatus> get status => select(_status);
  SourceListenable<MapEntry<String, Object>?> get error => select(_error);
  SourceListenable<bool> get isEmpty => select(_isEmpty);

  static bool _hasValue<V>(AbstractControlState<V> state) => state.value != null;
  static V? _value<V>(AbstractControlState<V> state) => state.value;
  static bool _pristine<V>(AbstractControlState<V> state) => state.pristine;
  static bool _dirty<V>(AbstractControlState<V> state) => state.dirty;
  static bool _touched<V>(AbstractControlState<V> state) => state.touched;
  static ControlStatus _status<V>(AbstractControlState<V> state) => state.status;
  static MapEntry<String, Object>? _error<V>(AbstractControlState<V> state) => state.error;
  static bool _isEmpty(AbstractControlState<Object?> state) {
    final value = state.value;
    return value == null ||
        (value is String && value.isEmpty) ||
        (value is Iterable && value.isEmpty) ||
        (value is Map && value.isEmpty);
  }
}

extension ControlStatusSourceExtensions on SourceListenable<ControlStatus> {
  SourceListenable<bool> get enabled => select(_enabled);
  SourceListenable<bool> get disabled => select(_disabled);
  SourceListenable<bool> get valid => select(_valid);

  static bool _enabled(ControlStatus status) => status != ControlStatus.disabled;
  static bool _disabled(ControlStatus status) => status == ControlStatus.disabled;
  static bool _valid(ControlStatus status) => status == ControlStatus.valid;
}

extension FormControlStateSource<V> on FormControl<V> {
  SourceListenable<FormControlState<V>> get source => _FormControlStateSource(this);
}

extension FormControlStateSourceExtensions<V> on SourceListenable<FormControlState<V?>> {
  SourceListenable<bool> get hasFocus => select(_hasFocus);

  static bool _hasFocus<V>(FormControlState<V?> state) => state.hasFocus;
}

@immutable
class AbstractControlState<V> {
  final V? value;
  final bool pristine;
  final bool touched;
  final Map<String, Object> errors;
  final ControlStatus status;

  bool get dirty => !pristine;
  bool get hasErrors => errors.isNotEmpty;

  MapEntry<String, Object>? get error {
    if (!hasErrors || !_showErrors) return null;
    return errors.entries.first;
  }

  bool get _showErrors => status == ControlStatus.invalid && touched;

  const AbstractControlState({
    required this.value,
    required this.pristine,
    required this.touched,
    required this.errors,
    required this.status,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AbstractControlState<V> &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          pristine == other.pristine &&
          touched == other.touched &&
          errors == other.errors &&
          status == other.status;

  @override
  int get hashCode => Object.hash(value, pristine, touched, errors, status);
}

@immutable
class FormControlState<V> extends AbstractControlState<V?> {
  final bool hasFocus;

  const FormControlState({
    required super.value,
    required super.pristine,
    required super.touched,
    required super.errors,
    required super.status,
    required this.hasFocus,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormControlState<V> &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          pristine == other.pristine &&
          touched == other.touched &&
          errors == other.errors &&
          status == other.status &&
          hasFocus == other.hasFocus;

  @override
  int get hashCode => Object.hash(value, pristine, touched, errors, status, hasFocus);
}

final class _AbstractControlStateSource<V>
    extends _AbstractControlStateSourceBase<AbstractControl<V>, AbstractControlState<V?>> {
  _AbstractControlStateSource(super.control);

  @override
  AbstractControlState<V?> read() {
    return AbstractControlState(
      value: control.value,
      pristine: control.pristine,
      touched: control.touched,
      errors: control.errors,
      status: control.status,
    );
  }
}

final class _FormControlStateSource<V>
    extends _AbstractControlStateSourceBase<FormControl<V>, FormControlState<V>> {
  _FormControlStateSource(super.control);

  @override
  Stream<Object?>? get changes => control.focusChanges;

  @override
  FormControlState<V> read() {
    return FormControlState(
      value: control.value,
      pristine: control.pristine,
      touched: control.touched,
      errors: control.errors,
      status: control.status,
      hasFocus: control.hasFocus,
    );
  }
}

abstract base class _AbstractControlStateSourceBase<
  TControl extends AbstractControl<Object?>,
  TState extends AbstractControlState<Object?>
>
    extends SourceListenable<TState> {
  final TControl control;

  _AbstractControlStateSourceBase(this.control);

  Stream<Object?>? get changes => null;

  TState read();

  @override
  SourceSubscription<TState> listen(SourceListener<TState> listener) {
    var current = read();
    void onChange(_) {
      final previous = current;
      current = read();
      if (previous == current) return;
      Zone.current.runBinaryGuarded(listener, previous, current);
    }

    return _ControlSubscription(
      reader: () => current,
      statusSubscription: control.statusChanged.listen(onChange),
      valueSubscription: control.valueChanges.listen(onChange),
      touchSubscription: control.touchChanges.listen(onChange),
      changesSubscription: changes?.listen(onChange),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AbstractControlStateSourceBase<TControl, TState> &&
          runtimeType == other.runtimeType &&
          control == other.control;

  @override
  int get hashCode => control.hashCode;
}

final class _FormControlSource<TControl extends AbstractControl<Object?>>
    extends SourceListenable<TControl> {
  final TControl control;

  _FormControlSource(this.control);

  Stream<Object?>? get changes => null;

  @override
  SourceSubscription<TControl> listen(SourceListener<TControl> listener) {
    void onChange(_) => Zone.current.runBinaryGuarded(listener, control, control);

    return _ControlSubscription(
      reader: () => control,
      statusSubscription: control.statusChanged.listen(onChange),
      valueSubscription: control.valueChanges.listen(onChange),
      touchSubscription: control.touchChanges.listen(onChange),
      changesSubscription: changes?.listen(onChange),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _FormControlSource<TControl> &&
          runtimeType == other.runtimeType &&
          control == other.control;

  @override
  int get hashCode => control.hashCode;
}

final class _ControlSubscription<T> extends SourceSubscriptionBase<T> {
  final T Function() reader;
  final StreamSubscription<ControlStatus> statusSubscription;
  final StreamSubscription<Object?> valueSubscription;
  final StreamSubscription<bool> touchSubscription;
  final StreamSubscription<Object?>? changesSubscription;

  _ControlSubscription({
    required this.reader,
    required this.statusSubscription,
    required this.valueSubscription,
    required this.touchSubscription,
    required this.changesSubscription,
  });

  @override
  T onRead() => reader();

  @override
  void onCancel() {
    unawaited(statusSubscription.cancel());
    unawaited(valueSubscription.cancel());
    unawaited(touchSubscription.cancel());
    unawaited(changesSubscription?.cancel());
  }
}
