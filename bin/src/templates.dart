abstract final class Templates {
  static const (String, String) reactiveFormsSources = (
    'reactive_forms_sources.dart',
    r'''
// Version: 4.0.0

import 'package:reactive_forms/reactive_forms.dart';
// ignore: implementation_imports
import 'package:rivertion/src/internals.dart';

extension SourceAbstractControlExtension<C extends AbstractControl<T>, T> on C {
  AbstractControlSource<C, T> get source => AbstractControlSource._(this);
}

final class AbstractControlSource<C extends AbstractControl<T>, T> {
  final C _control;

  SourceListenable<ControlStatus> get status => _onStatus(null, _status);
  SourceListenable<bool> get pristine => _onStatus(null, _pristine);
  SourceListenable<bool> get dirty => _onStatus(null, _dirty);
  SourceListenable<Map<String, Object>> get errors => _onStatus(null, _errors);
  SourceListenable<bool> get hasErrors => _onStatus(null, _hasErrors);
  SourceListenable<bool> hasError(String errorCode, [String? path]) =>
      _onStatus((errorCode, path), _hasError);
  SourceListenable<Object?> getError(String errorCode, [String? path]) =>
      _onStatus((errorCode, path), _getError);

  SourceListenable<T?> get value => _AbstractControlValueSourceListenable(_control);
  SourceListenable<bool> get isEmpty => value.select(_isEmpty);

  SourceListenable<bool> get touched => _AbstractControlTouchSourceListenable(_control);

  AbstractControlSource._(this._control);

  SourceListenable<R> _onStatus<A, R>(A arg, R Function(A arg, C control) selector) =>
      _AbstractControlStatusSourceListenable(_control, arg, selector);

  static ControlStatus _status(_, AbstractControl<Object?> control) => control.status;
  static bool _pristine(_, AbstractControl<Object?> control) => control.pristine;
  static bool _dirty(_, AbstractControl<Object?> control) => control.dirty;
  static Map<String, Object> _errors(_, AbstractControl<Object?> control) => control.errors.cast();
  static bool _hasErrors(_, AbstractControl<Object?> control) => control.hasErrors;
  static bool _hasError((String, String?) arg, AbstractControl<Object?> control) =>
      control.hasError(arg.$1, arg.$2);
  static Object? _getError((String, String?) arg, AbstractControl<Object?> control) =>
      control.getError(arg.$1, arg.$2);

  static bool _isEmpty(Object? value) => switch (value) {
    null => true,
    String() => value.isEmpty,
    Iterable() => value.isEmpty,
    Map() => value.isEmpty,
    _ => false,
  };
}

extension SourcesFormGroupExtensions on AbstractControlSource<FormGroup, Map<String, Object?>> {
  SourceListenable<Map<String, AbstractControl<Object?>>> get controls =>
      _FormControlCollectionSourceListenable(_control, _controls);

  static Map<String, AbstractControl<Object?>> _controls(FormGroup control) => control.controls;
}

extension SourcesFormArrayExtensions<T> on AbstractControlSource<FormArray<T>, List<T?>> {
  SourceListenable<List<AbstractControl<T>>> get controls =>
      _FormControlCollectionSourceListenable(_control, _controls);

  static List<AbstractControl<T>> _controls<T>(FormArray<T> control) => control.controls;
}

extension ControlStatusSourceExtensions on SourceListenable<ControlStatus> {
  SourceListenable<bool> get pending => select(_pending);
  SourceListenable<bool> get valid => select(_valid);
  SourceListenable<bool> get invalid => select(_invalid);
  SourceListenable<bool> get disabled => select(_disabled);
  SourceListenable<bool> get enabled => select(_enabled);

  static bool _pending(ControlStatus status) => status == ControlStatus.pending;
  static bool _valid(ControlStatus status) => status == ControlStatus.valid;
  static bool _invalid(ControlStatus status) => status == ControlStatus.invalid;
  static bool _disabled(ControlStatus status) => status == ControlStatus.disabled;
  static bool _enabled(ControlStatus status) => !_disabled(status);
}

final class _AbstractControlStatusSourceListenable<C extends AbstractControl<Object?>, A, R>
    extends SourceListenable<R> {
  final C _control;
  final A _arg;
  final R Function(A arg, C control) _selector;

  _AbstractControlStatusSourceListenable(this._control, this._arg, this._selector);

  @override
  SourceSubscription<R> listen(SourceListener<R> listener) {
    var current = _selector(_arg, _control);
    final subscription = _control.statusChanged.listen((_) {
      final previous = current;
      current = _selector(_arg, _control);
      if (previous == current) return;
      listener(previous, current);
    });
    return SourceSubscriptionBuilder(() => current, subscription.cancel);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AbstractControlStatusSourceListenable<C, A, R> &&
          runtimeType == other.runtimeType &&
          identical(_control, other._control) &&
          _arg == other._arg &&
          identical(_selector, other._selector);

  @override
  int get hashCode => Object.hash(runtimeType, _control, _arg, _selector);
}

final class _AbstractControlValueSourceListenable<T> extends SourceListenable<T?> {
  final AbstractControl<T> _control;

  _AbstractControlValueSourceListenable(this._control);

  @override
  SourceSubscription<T?> listen(SourceListener<T?> listener) {
    var current = _control.value;
    final subscription = _control.valueChanges.listen((value) {
      final previous = current;
      current = value;
      if (previous == current) return;
      listener(previous, current);
    });
    return SourceSubscriptionBuilder(() => current, subscription.cancel);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AbstractControlValueSourceListenable<T> &&
          runtimeType == other.runtimeType &&
          identical(_control, other._control);

  @override
  int get hashCode => Object.hash(runtimeType, _control);
}

final class _AbstractControlTouchSourceListenable extends SourceListenable<bool> {
  final AbstractControl<Object?> _control;

  _AbstractControlTouchSourceListenable(this._control);

  @override
  SourceSubscription<bool> listen(SourceListener<bool> listener) {
    var current = _control.touched;
    final subscription = _control.touchChanges.listen((value) {
      final previous = current;
      current = value;
      if (previous == current) return;
      listener(previous, current);
    });
    return SourceSubscriptionBuilder(() => current, subscription.cancel);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AbstractControlTouchSourceListenable &&
          runtimeType == other.runtimeType &&
          identical(_control, other._control);

  @override
  int get hashCode => Object.hash(runtimeType, _control);
}

final class _FormControlCollectionSourceListenable<C extends FormControlCollection, R>
    extends SourceListenable<R> {
  final C _control;
  final R Function(C control) _selector;

  _FormControlCollectionSourceListenable(this._control, this._selector);

  @override
  SourceSubscription<R> listen(SourceListener<R> listener) {
    var current = _selector(_control);
    final subscription = _control.collectionChanges.listen((value) {
      final previous = current;
      current = _selector(_control);
      if (previous == current) return;
      listener(previous, current);
    });
    return SourceSubscriptionBuilder(() => current, subscription.cancel);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _FormControlCollectionSourceListenable<C, R> &&
          runtimeType == other.runtimeType &&
          identical(_control, other._control) &&
          _selector == other._selector;

  @override
  int get hashCode => Object.hash(runtimeType, _control, _selector);
}
''',
  );

  static const (String, String) blocSource = (
    'bloc_source.dart',
    '''
// Version: 4.0.0

import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
// ignore: implementation_imports
import 'package:rivertion/src/internals.dart';

extension SourceStateStreamableExtension<T> on StateStreamable<T> {
  SourceListenable<T> get source => _StateStreamableSource(this);
}

final class _StateStreamableSource<T> extends SourceListenable<T> {
  final StateStreamable<T> _stateStreamable;

  _StateStreamableSource(this._stateStreamable);

  @override
  SourceSubscription<T> listen(SourceListener<T> onChange) {
    var current = _stateStreamable.state;

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
          identical(_stateStreamable, other._stateStreamable);

  @override
  int get hashCode => _stateStreamable.hashCode;
}
''',
  );

  static const (String, String) riverpodRefExtensions = (
    'riverpod_ref_extensions.dart',
    '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: implementation_imports
import 'package:rivertion/src/internals.dart';

extension SourcesRefExtension on Ref {
  T watchSource<T>(Source<T> source) {
    final subscription = source.listenable.listen((_, _) => invalidateSelf(asReload: true));
    onDispose(subscription.cancel);
    return subscription.read();
  }

  SourceSubscription<T> listenSource<T>(Source<T> source, SourceListener<T> listener) {
    final subscription = source.listenable.listen(listener);
    final dispositionRemover = onDispose(subscription.cancel);
    return SourceSubscriptionBuilder(subscription.read, () {
      dispositionRemover();
      subscription.cancel();
    });
  }

  SourceSubscription<T> listenSourceImmediately<T>(
    Source<T> source,
    SourceImmediatelyListener<T> listener,
  ) {
    final subscription = source.listenable.listenImmediately(listener);
    final dispositionRemover = onDispose(subscription.cancel);
    return SourceSubscriptionBuilder(subscription.read, () {
      dispositionRemover();
      subscription.cancel();
    });
  }
}
''',
  );

  static const (String, String) riverpodSourceConsumer = (
    'riverpod_source_consumer.dart',
    '''
// Version: 4.0.0

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
}

final class _NotifierStateSource<T> extends SourceListenable<T> {
  final StateNotifier<T> _notifier;

  _NotifierStateSource(this._notifier);

  @override
  SourceSubscription<T> listen(SourceListener<T> onChange) {
    var isFirstFire = true;
    late T current;
    final listenerRemover = _notifier.addListener(fireImmediately: true, (next) {
      if (isFirstFire) {
        isFirstFire = false;
        current = next;
      } else {
        final previous = current;
        current = next;
        Zone.current.runBinaryGuarded(onChange, previous, next);
      }
    });
    return SourceSubscriptionBuilder(() => current, listenerRemover);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _NotifierStateSource<T> &&
          runtimeType == other.runtimeType &&
          identical(_notifier, other._notifier);

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
