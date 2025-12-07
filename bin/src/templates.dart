abstract final class Templates {
  static const (String, String) reactiveFormsSources = (
    'reactive_forms_sources.dart',
    '''
// Version: 3.0.0

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reactive_forms/reactive_forms.dart';
// ignore: implementation_imports
import 'package:rivertion/src/internals.dart';

extension AbstractControlStateSource<V> on AbstractControl<V> {
  SourceListenable<AbstractControlState<V?>> get source => _AbstractControlStateSource(this);

  @Deprecated('In favour of source.select')
  SourceListenable<R> select<R>(R Function(AbstractControl<V> control) selector) =>
      _FormControlSource(this).select(selector);
}

extension ControlStateSource<C extends AbstractControl<Object?>> on C {
  SourceListenable<R> sourceBy<R>(R Function(C control) selector) =>
      _FormControlSource(this).select(selector);

  @Deprecated('In favour of sourceBy')
  SourceListenable<R> select<R>(R Function(C control) selector) => sourceBy(selector);
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
  final V? defaultValue;
  final bool hasFocus;

  const FormControlState({
    required super.value,
    required super.pristine,
    required super.touched,
    required super.errors,
    required super.status,
    required this.defaultValue,
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
          defaultValue == other.defaultValue &&
          hasFocus == other.hasFocus;

  @override
  int get hashCode => Object.hash(value, pristine, touched, errors, status, defaultValue, hasFocus);
}

final class _AbstractControlStateSource<V>
    extends _AbstractControlStateSourceBase<AbstractControl<V>, AbstractControlState<V?>> {
  _AbstractControlStateSource(super.control);

  @override
  AbstractControlState<V?> read() => AbstractControlState(
    value: control.value,
    pristine: control.pristine,
    touched: control.touched,
    errors: control.errors,
    status: control.status,
  );
}

final class _FormControlStateSource<V>
    extends _AbstractControlStateSourceBase<FormControl<V>, FormControlState<V>> {
  _FormControlStateSource(super.control);

  @override
  Stream<Object?>? get changes => control.focusChanges;

  @override
  FormControlState<V> read() => FormControlState(
    value: control.value,
    pristine: control.pristine,
    touched: control.touched,
    errors: control.errors,
    status: control.status,
    defaultValue: control.defaultValue,
    hasFocus: control.hasFocus,
  );
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
''',
  );

  static const (String, String) blocSource = (
    'bloc_source.dart',
    '''
// Version: 3.0.0

import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
// ignore: implementation_imports
import 'package:rivertion/src/internals.dart';

extension SourceStateStreamableExtension<T> on StateStreamable<T> {
  SourceListenable<T> get source => _StateStreamableSource(this);

  @Deprecated('In favour of source.select')
  SourceListenable<R> select<R>(R Function(T state) selector) => source.select(selector);

  @Deprecated('In favour of source.selectWith')
  SourceListenable<R> selectWith<R, A>(A arg, R Function(A arg, T state) selector) =>
      source.selectWith(arg, selector);

  @Deprecated('In favour of source.where')
  SourceListenable<T> where(bool Function(T previous, T next) condition) => source.where(condition);
}

final class _StateStreamableSource<T> extends SourceListenable<T> {
  final StateStreamable<T> _stateStreamable;

  _StateStreamableSource(this._stateStreamable);

  @override
  SourceSubscription<T> listen(SourceListener<T> onChange) {
    var current = _stateStreamable.state;

    // ignore: cancel_subscriptions
    final streamSubscription = _stateStreamable.stream.listen((next) {
      final previous = current;
      current = next;
      Zone.current.runBinaryGuarded(onChange, previous, next);
    });

    return SourceSubscriptionBuilder(() => current, streamSubscription.cancel);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _StateStreamableSource<T> &&
          runtimeType == other.runtimeType &&
          _stateStreamable == other._stateStreamable;

  @override
  int get hashCode => _stateStreamable.hashCode;
}
''',
  );

  static const (String, String) riverpodSourceConsumer = (
    'riverpod_source_consumer.dart',
    r'''
// Version: 3.0.0

import 'dart:async';

import 'package:flutter/widgets.dart';
// ignore: implementation_imports
import 'package:flutter_riverpod/src/internals.dart';
// ignore: implementation_imports
import 'package:rivertion/src/internals.dart';

extension type SourceWidgetRef._(_SourceConsumerStatefulElement _element)
    implements SourceRef, WidgetRef {}

class SourceConsumer extends SourceConsumerStatefulWidget {
  final Widget Function(BuildContext context, SourceWidgetRef ref, Widget? child) builder;
  final Widget? child;

  const SourceConsumer({super.key, required this.builder, this.child});

  Widget build(BuildContext context, SourceWidgetRef ref) => builder(context, ref, child);

  @override
  SourceConsumerState<SourceConsumerStatefulWidget> createState() => _SourceConsumerState();
}

abstract class SourceConsumerWidget extends SourceConsumerStatefulWidget {
  const SourceConsumerWidget({super.key});

  Widget build(BuildContext context, SourceWidgetRef ref);

  @override
  SourceConsumerState<SourceConsumerStatefulWidget> createState() => _SourceConsumerState();
}

class _SourceConsumerState extends SourceConsumerState<SourceConsumerWidget> {
  @override
  Widget build(BuildContext context) => widget.build(context, ref);
}

abstract class SourceConsumerStatefulWidget extends ConsumerStatefulWidget {
  const SourceConsumerStatefulWidget({super.key});

  @override
  SourceConsumerState<SourceConsumerStatefulWidget> createState();

  @override
  // ignore: invalid_use_of_internal_member
  ConsumerStatefulElement createElement() => _SourceConsumerStatefulElement(this);
}

abstract class SourceConsumerState<T extends SourceConsumerStatefulWidget>
    extends ConsumerState<T> {
  @override
  // ignore: overridden_fields
  late final SourceWidgetRef ref = SourceWidgetRef._(context as _SourceConsumerStatefulElement);
}

// ignore: invalid_use_of_internal_member
final class _SourceConsumerStatefulElement extends ConsumerStatefulElement
    with SourceStatefulElementMixin {
  _SourceConsumerStatefulElement(SourceConsumerStatefulWidget super.widget);
}

extension SourceStateNotifierExtension<T> on StateNotifier<T> {
  SourceListenable<T> get source => _NotifierStateSource(this);

  @Deprecated('In favour of source.select')
  SourceListenable<R> select<R>(R Function(T state) selector) => source.select(selector);

  @Deprecated('In favour of source.selectWith')
  SourceListenable<R> selectWith<R, A>(A arg, R Function(A arg, T state) selector) =>
      source.selectWith(arg, selector);

  @Deprecated('In favour of source.where')
  SourceListenable<T> where(bool Function(T previous, T next) condition) => source.where(condition);
}

final class _NotifierStateSource<T> extends SourceListenable<T> {
  final StateNotifier<T> _notifier;

  _NotifierStateSource(this._notifier);

  @override
  SourceSubscription<T> listen(SourceListener<T> onChange) {
    (T,)? current;
    final listenerRemover = _notifier.addListener(fireImmediately: true, (next) {
      final previous = current;
      current = (next,);
      if (previous != null) {
        Zone.current.runBinaryGuarded(onChange, previous.$1, next);
      }
    });
    return SourceSubscriptionBuilder(() => current!.$1, listenerRemover);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _NotifierStateSource<T> &&
          runtimeType == other.runtimeType &&
          _notifier == other._notifier;

  @override
  int get hashCode => _notifier.hashCode;
}
''',
  );

  static const (String, String) riverpodMutation = (
    'riverpod_mutation.dart',
    r'''
// Version: 3.0.0

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:rivertion/rivertion.dart';

import 'riverpod_source_consumer.dart';

abstract class MutationRef {
  final ProviderContainer _container;

  MutationRef(this._container);

  bool exists(ProviderBase<Object?> provider) => _container.exists(provider);

  void invalidate(ProviderOrFamily provider) => _container.invalidate(provider);

  T read<T>(ProviderListenable<T> provider);

  T refresh<T>(Refreshable<T> provider);

  void updateProgress(double value);
}

extension MutationNotififierExtension on SourceWidgetRef {
  MutationNotifier<A, R> mutation<A, R>(Future<R> Function(MutationRef ref, A arg) mutator) {
    final mutation = MutationNotifier<A, R>(this, mutator);
    onDispose(mutation.dispose);
    return mutation;
  }
}

typedef ErrorMutationListener = FutureOr<void> Function(Object error);
typedef DataMutationListener<Result> = FutureOr<void> Function(Result result);
typedef ResultMutationListener<Result> = FutureOr<void> Function(Object? error, Result? result);

class MutationNotifier<TArg, TResult> extends SourceNotifier<MutationState<TResult>> {
  final SourceWidgetRef _ref;
  final Future<TResult> Function(MutationRef ref, TArg arg) _mutator;

  MutationNotifier(this._ref, this._mutator) : super(IdleMutation<TResult>());

  void call(
    TArg arg, {
    required ErrorMutationListener? onError,
    DataMutationListener<TResult>? onSuccess,
    ResultMutationListener<TResult>? onSettled,
  }) => unawaited(run(arg, onError: onError, onSuccess: onSuccess, onSettled: onSettled)..ignore());

  Future<TResult> run(
    TArg arg, {
    ErrorMutationListener? onError,
    DataMutationListener<TResult>? onSuccess,
    ResultMutationListener<TResult>? onSettled,
  }) async {
    if (!mounted) throw StateError("Can't mutate if $this is closed!");

    state = state.toLoading(arg: arg);

    final ref = _MutationRef(_ref.container, this, arg);
    try {
      final result = await _mutator(ref, arg);
      ref.dispose();
      if (!mounted) return result;

      unawaited(_tryCall1(onSuccess, result));
      unawaited(_tryCall2(onSettled, null, result));

      state = state.toSuccess(arg: arg, data: result);
      return result;
    } catch (error) {
      ref.dispose();
      if (!mounted) rethrow;

      unawaited(_tryCall1(onError, error));
      unawaited(_tryCall2(onSettled, error, null));

      state = state.toFailed(arg: arg, error: error);
      rethrow;
    }
  }

  void _updateProgress(TArg arg, double value) {
    if (state is! LoadingMutation<TResult>) {
      throw StateError("$this isn't mutating! Cant update progress state.");
    }
    state = state.toLoading(arg: arg, progress: value);
  }

  Future<void>? _tryCall1<T1>(FutureOr<void> Function(T1)? fn, T1 $1) async {
    if (fn == null) return;
    try {
      await fn($1);
    } catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  Future<void>? _tryCall2<T1, T2>(FutureOr<void> Function(T1, T2)? fn, T1 $1, T2 $2) async {
    if (fn == null) return;
    try {
      await fn($1, $2);
    } catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }

  @override
  String toString() => 'MutationNotifier<$TArg, $TResult>';
}

sealed class MutationState<TData> {
  final Set<Object?> args;

  const MutationState({required this.args});

  bool get isMutating => args.isNotEmpty;

  bool get isIdle => this is IdleMutation<TData>;
  bool get isLoading => this is LoadingMutation<TData>;
  bool get isFailed => this is FailedMutation<TData>;
  bool get isSuccess => this is SuccessMutation<TData>;

  Object? get errorOrNull => whenOrNull(failed: (error) => error);

  double? get progressOrNull {
    final state = this;
    return state is LoadingMutation<TData> ? state.status.values.singleOrNull : null;
  }

  Map<Object?, double?> get status {
    final state = this;
    return state is LoadingMutation<TData> ? state.status : const {};
  }

  const factory MutationState.idle() = IdleMutation<TData>;
  const factory MutationState.loading({
    required Set<Object?> args,
    required Map<Object?, double?> status,
  }) = LoadingMutation<TData>;
  const factory MutationState.failed({required Set<Object?> args, required Object error}) =
      FailedMutation<TData>;
  const factory MutationState.success({required Set<Object?> args, required TData data}) =
      SuccessMutation<TData>;

  MutationState<TData> toIdle() => IdleMutation<TData>();

  MutationState<TData> toLoading({required Object? arg, double? progress}) =>
      LoadingMutation<TData>(args: {...args, arg}, status: {...status, arg: progress});

  MutationState<TData> toFailed({required Object? arg, required Object error}) {
    return FailedMutation(args: {...args}..remove(arg), error: error);
  }

  MutationState<TData> toSuccess({required Object? arg, required TData data}) {
    return SuccessMutation(args: {...args}..remove(arg), data: data);
  }

  R map<R>({
    required R Function(IdleMutation<TData> state) idle,
    required R Function(LoadingMutation<TData> state) loading,
    required R Function(FailedMutation<TData> state) failed,
    required R Function(SuccessMutation<TData> state) success,
  }) {
    final state = this;
    return switch (state) {
      IdleMutation<TData>() => idle(state),
      LoadingMutation<TData>() => loading(state),
      FailedMutation<TData>() => failed(state),
      SuccessMutation<TData>() => success(state),
    };
  }

  R maybeMap<R>({
    R Function(IdleMutation<TData> state)? idle,
    R Function(LoadingMutation<TData> state)? loading,
    R Function(FailedMutation<TData> state)? failed,
    R Function(SuccessMutation<TData> state)? success,
    required R Function(MutationState<TData>) orElse,
  }) {
    return map(
      idle: idle ?? orElse,
      loading: loading ?? orElse,
      failed: failed ?? orElse,
      success: success ?? orElse,
    );
  }

  R? mapOrNull<R>({
    R Function(IdleMutation<TData> state)? idle,
    R Function(LoadingMutation<TData> state)? loading,
    R Function(FailedMutation<TData> state)? failed,
    R Function(SuccessMutation<TData> state)? success,
  }) {
    R? orNull(_) => null;
    return map(
      idle: idle ?? orNull,
      loading: loading ?? orNull,
      failed: failed ?? orNull,
      success: success ?? orNull,
    );
  }

  R when<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(Object error) failed,
    required R Function(TData data) success,
  }) {
    return map(
      idle: (state) => idle(),
      loading: (state) => loading(),
      failed: (state) => failed(state.error),
      success: (state) => success(state.data),
    );
  }

  R maybeWhen<R>({
    R Function()? idle,
    R Function()? loading,
    R Function(Object error)? failed,
    R Function(TData data)? success,
    required R Function() orElse,
  }) {
    return map(
      idle: (_) => idle == null ? orElse() : idle(),
      loading: (_) => loading == null ? orElse() : loading(),
      failed: (state) => failed == null ? orElse() : failed(state.error),
      success: (state) => success == null ? orElse() : success(state.data),
    );
  }

  R? whenOrNull<R>({
    R Function()? idle,
    R Function()? loading,
    R Function(Object error)? failed,
    R Function(TData data)? success,
  }) {
    return map(
      idle: (_) => idle?.call(),
      loading: (_) => loading?.call(),
      failed: (state) => failed?.call(state.error),
      success: (state) => success?.call(state.data),
    );
  }
}

class IdleMutation<TData> extends MutationState<TData> {
  const IdleMutation() : super(args: const {});

  @override
  R map<R>({
    required R Function(IdleMutation<TData> state) idle,
    required R Function(LoadingMutation<TData> state) loading,
    required R Function(FailedMutation<TData> state) failed,
    required R Function(SuccessMutation<TData> state) success,
  }) {
    return idle(this);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdleMutation<TData> &&
          runtimeType == other.runtimeType &&
          setEquals(args, other.args);

  @override
  int get hashCode => args.hashCode;
}

class LoadingMutation<TData> extends MutationState<TData> {
  @override
  final Map<Object?, double?> status;

  const LoadingMutation({required super.args, required this.status});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadingMutation<TData> &&
          runtimeType == other.runtimeType &&
          setEquals(args, other.args) &&
          mapEquals(status, other.status);

  @override
  int get hashCode => Object.hash(args, status);
}

class FailedMutation<TData> extends MutationState<TData> {
  final Object error;

  const FailedMutation({required super.args, required this.error});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailedMutation<TData> &&
          runtimeType == other.runtimeType &&
          setEquals(args, other.args) &&
          error == other.error;

  @override
  int get hashCode => Object.hash(args, error);
}

class SuccessMutation<TData> extends MutationState<TData> {
  final TData data;

  const SuccessMutation({required super.args, required this.data});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuccessMutation<TData> &&
          runtimeType == other.runtimeType &&
          const DeepCollectionEquality().equals(data, other.data);

  @override
  int get hashCode => Object.hash(args, data);
}

class _MutationRef<TArg> extends MutationRef {
  MutationNotifier? _notifier;
  final TArg _arg;

  final _subscriptions = <ProviderListenable, ProviderSubscription>{};

  _MutationRef(super._container, this._notifier, this._arg);

  @override
  T read<T>(ProviderListenable<T> provider) {
    _subscriptions.putIfAbsent(provider, () => _container.listen(provider, (_, _) {}));
    return _container.read(provider);
  }

  @override
  T refresh<T>(Refreshable<T> provider) {
    _subscriptions.putIfAbsent(provider, () => _container.listen(provider, (_, _) {}));
    return _container.refresh(provider);
  }

  @override
  void updateProgress(double value) => _notifier?._updateProgress(_arg, value);

  void dispose() {
    for (final subscription in _subscriptions.values) {
      subscription.close();
    }
    _notifier = null;
  }
}
''',
  );
}
