abstract final class Templates {
  static const (String, String) blocProvider = (
    'bloc_provider.dart',
    r'''
// Version: 4.0.0

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
// ignore: implementation_imports
import 'package:riverpod/src/internals.dart';

// ignore: invalid_use_of_internal_member
final _family = NotifierProviderFamily.internal((_) => throw UnimplementedError());

extension StateStremableProviderExtension<T> on StateStreamable<T> {
  ProviderListenable<T> get provider =>
      // ignore: invalid_use_of_internal_member
      NotifierProvider.internal(
        () => _StateStreamableNotifier(this),
        name: '$this',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
        retry: (_, _) => null,
        from: _family,
        argument: this,
      );
}

class _StateStreamableNotifier<T> extends Notifier<T> {
  final StateStreamable<T> stateStreamable;

  _StateStreamableNotifier(this.stateStreamable);

  @override
  T build() {
    final subscription = stateStreamable.stream.listen((state) => this.state = state);
    ref.onDispose(subscription.cancel);
    return stateStreamable.state;
  }
}
''',
  );

  static const (String, String) reactiveFormsProviders = (
    'reactive_forms_providers.dart',
    r'''
// Version: 4.0.0

import 'package:reactive_forms/reactive_forms.dart';
// ignore: implementation_imports
import 'package:riverpod/src/internals.dart';

// ignore: invalid_use_of_internal_member
final _family = NotifierProviderFamily.internal((_) => throw UnimplementedError());

extension AbstractControlProviderExtension<T extends AbstractControl> on T {
  ProviderListenable<T> get provider =>
      // ignore: invalid_use_of_internal_member
      NotifierProvider.internal(
        () => _AbstractControlNotifier(this),
        name: '$this',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
        retry: (_, _) => null,
        from: _family,
        argument: this,
      );
}

class _AbstractControlNotifier<T extends AbstractControl> extends Notifier<T> {
  final T control;

  _AbstractControlNotifier(this.control);

  @override
  T build() {
    final statusSubscription = control.statusChanged.listen((_) => ref.notifyListeners());
    ref.onDispose(statusSubscription.cancel);
    final valueSubscription = control.valueChanges.listen((_) => ref.notifyListeners());
    ref.onDispose(valueSubscription.cancel);
    final touchSubscription = control.touchChanges.listen((_) => ref.notifyListeners());
    ref.onDispose(touchSubscription.cancel);
    return control;
  }
}

extension ProviderAbstractControlExtensions<T extends AbstractControl<V>, V>
    on ProviderListenable<T> {
  ProviderListenable<ControlStatus> get status => select((control) => control.status);
  ProviderListenable<bool> get pristine => select((control) => control.pristine);
  ProviderListenable<bool> get dirty => select((control) => control.dirty);
  ProviderListenable<Map<String, Object>> get errors => select((control) => control.errors.cast());
  ProviderListenable<bool> get hasErrors => select((control) => control.hasErrors);

  ProviderListenable<V?> get value => select((control) => control.value);
  ProviderListenable<bool> get isEmpty => select(_isEmpty);

  ProviderListenable<bool> get touched => select((control) => control.touched);

  static bool _isEmpty(Object? value) => switch (value) {
    null => true,
    String() => value.isEmpty,
    Iterable() => value.isEmpty,
    Map() => value.isEmpty,
    _ => false,
  };
}

extension FormControlCollectionProviderExtension<T extends FormControlCollection> on T {
  ProviderListenable<T> get provider =>
      // ignore: invalid_use_of_internal_member
      NotifierProvider.internal(
        () => _FormControlCollectionNotifier(this),
        name: '$this',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
        retry: (_, _) => null,
        from: _family,
        argument: this,
      );
}

class _FormControlCollectionNotifier<T extends FormControlCollection> extends Notifier<T> {
  final T control;

  _FormControlCollectionNotifier(this.control);

  @override
  T build() {
    final statusSubscription = control.statusChanged.listen((_) => ref.notifyListeners());
    ref.onDispose(statusSubscription.cancel);
    final valueSubscription = control.valueChanges.listen((_) => ref.notifyListeners());
    ref.onDispose(valueSubscription.cancel);
    final touchSubscription = control.touchChanges.listen((_) => ref.notifyListeners());
    ref.onDispose(touchSubscription.cancel);
    final collectionSubscription = control.collectionChanges.listen((_) => ref.notifyListeners());
    ref.onDispose(collectionSubscription.cancel);
    return control;
  }
}

extension ProviderFormGroupExtensions on ProviderListenable<FormGroup> {
  ProviderListenable<Map<String, AbstractControl<Object?>>> get controls =>
      select((control) => control.controls);
}

extension ProviderFormArrayExtensions<T> on ProviderListenable<FormArray<T>> {
  ProviderListenable<List<AbstractControl<T>>> get controls =>
      select((control) => control.controls);
}

extension ProviderControlStatusExtensions on ProviderListenable<ControlStatus> {
  ProviderListenable<bool> get pending => select(_pending);
  ProviderListenable<bool> get valid => select(_valid);
  ProviderListenable<bool> get invalid => select(_invalid);
  ProviderListenable<bool> get disabled => select(_disabled);
  ProviderListenable<bool> get enabled => select(_enabled);

  static bool _pending(ControlStatus status) => status == ControlStatus.pending;
  static bool _valid(ControlStatus status) => status == ControlStatus.valid;
  static bool _invalid(ControlStatus status) => status == ControlStatus.invalid;
  static bool _disabled(ControlStatus status) => status == ControlStatus.disabled;
  static bool _enabled(ControlStatus status) => !_disabled(status);
}
''',
  );

  static const (String, String) riverpodMutation = (
    'riverpod_mutation.dart',
    r'''
// // Version: 3.0.0
//
// import 'dart:async';
//
// import 'package:collection/collection.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/misc.dart';
// import 'package:rivertion/rivertion.dart';
//
// abstract class MutationRef {
//   final ProviderContainer _container;
//
//   MutationRef(this._container);
//
//   bool exists(ProviderBase<Object?> provider) => _container.exists(provider);
//
//   void invalidate(ProviderOrFamily provider) => _container.invalidate(provider);
//
//   T read<T>(ProviderListenable<T> provider);
//
//   T refresh<T>(Refreshable<T> provider);
//
//   void updateProgress(double value);
// }
//
// extension MutationNotififierExtension on WidgetRef {
//   MutationNotifier<A, R> mutation<A, R>(Future<R> Function(MutationRef ref, A arg) mutator) {
//     final mutation = MutationNotifier<A, R>(this, mutator);
//     onDispose(mutation.dispose);
//     return mutation;
//   }
// }
//
// typedef ErrorMutationListener = FutureOr<void> Function(Object error);
// typedef DataMutationListener<Result> = FutureOr<void> Function(Result result);
// typedef ResultMutationListener<Result> = FutureOr<void> Function(Object? error, Result? result);
//
// class MutationNotifier<TArg, TResult> extends SourceNotifier<MutationState<TResult>> {
//   final SourceRef _ref;
//   final Future<TResult> Function(MutationRef ref, TArg arg) _mutator;
//
//   MutationNotifier(this._ref, this._mutator) : super(IdleMutation<TResult>());
//
//   void call(
//     TArg arg, {
//     required ErrorMutationListener? onError,
//     DataMutationListener<TResult>? onSuccess,
//     ResultMutationListener<TResult>? onSettled,
//   }) => unawaited(run(arg, onError: onError, onSuccess: onSuccess, onSettled: onSettled)..ignore());
//
//   Future<TResult> run(
//     TArg arg, {
//     ErrorMutationListener? onError,
//     DataMutationListener<TResult>? onSuccess,
//     ResultMutationListener<TResult>? onSettled,
//   }) async {
//     if (!mounted) throw StateError("Can't mutate if $this is closed!");
//
//     state = state.toLoading(arg: arg);
//
//     final ref = _MutationRef(ProviderScope.containerOf(_ref.context, listen: false), this, arg);
//     try {
//       final result = await _mutator(ref, arg);
//       ref.dispose();
//       if (!mounted) return result;
//
//       unawaited(_tryCall1(onSuccess, result));
//       unawaited(_tryCall2(onSettled, null, result));
//
//       state = state.toSuccess(arg: arg, data: result);
//       return result;
//     } catch (error) {
//       ref.dispose();
//       if (!mounted) rethrow;
//
//       unawaited(_tryCall1(onError, error));
//       unawaited(_tryCall2(onSettled, error, null));
//
//       state = state.toFailed(arg: arg, error: error);
//       rethrow;
//     }
//   }
//
//   void _updateProgress(TArg arg, double value) {
//     if (state is! LoadingMutation<TResult>) {
//       throw StateError("$this isn't mutating! Cant update progress state.");
//     }
//     state = state.toLoading(arg: arg, progress: value);
//   }
//
//   Future<void>? _tryCall1<T1>(FutureOr<void> Function(T1)? fn, T1 $1) async {
//     if (fn == null) return;
//     try {
//       await fn($1);
//     } catch (error, stackTrace) {
//       Zone.current.handleUncaughtError(error, stackTrace);
//     }
//   }
//
//   Future<void>? _tryCall2<T1, T2>(FutureOr<void> Function(T1, T2)? fn, T1 $1, T2 $2) async {
//     if (fn == null) return;
//     try {
//       await fn($1, $2);
//     } catch (error, stackTrace) {
//       Zone.current.handleUncaughtError(error, stackTrace);
//     }
//   }
//
//   @override
//   String toString() => 'MutationNotifier<$TArg, $TResult>';
// }
//
// sealed class MutationState<TData> {
//   final Set<Object?> args;
//
//   const MutationState({required this.args});
//
//   bool get isMutating => args.isNotEmpty;
//
//   bool get isIdle => this is IdleMutation<TData>;
//   bool get isLoading => this is LoadingMutation<TData>;
//   bool get isFailed => this is FailedMutation<TData>;
//   bool get isSuccess => this is SuccessMutation<TData>;
//
//   Object? get errorOrNull => whenOrNull(failed: (error) => error);
//
//   double? get progressOrNull {
//     final state = this;
//     return state is LoadingMutation<TData> ? state.status.values.singleOrNull : null;
//   }
//
//   Map<Object?, double?> get status {
//     final state = this;
//     return state is LoadingMutation<TData> ? state.status : const {};
//   }
//
//   const factory MutationState.idle() = IdleMutation<TData>;
//   const factory MutationState.loading({
//     required Set<Object?> args,
//     required Map<Object?, double?> status,
//   }) = LoadingMutation<TData>;
//   const factory MutationState.failed({required Set<Object?> args, required Object error}) =
//       FailedMutation<TData>;
//   const factory MutationState.success({required Set<Object?> args, required TData data}) =
//       SuccessMutation<TData>;
//
//   MutationState<TData> toIdle() => IdleMutation<TData>();
//
//   MutationState<TData> toLoading({required Object? arg, double? progress}) =>
//       LoadingMutation<TData>(args: {...args, arg}, status: {...status, arg: progress});
//
//   MutationState<TData> toFailed({required Object? arg, required Object error}) {
//     return FailedMutation(args: {...args}..remove(arg), error: error);
//   }
//
//   MutationState<TData> toSuccess({required Object? arg, required TData data}) {
//     return SuccessMutation(args: {...args}..remove(arg), data: data);
//   }
//
//   R map<R>({
//     required R Function(IdleMutation<TData> state) idle,
//     required R Function(LoadingMutation<TData> state) loading,
//     required R Function(FailedMutation<TData> state) failed,
//     required R Function(SuccessMutation<TData> state) success,
//   }) {
//     final state = this;
//     return switch (state) {
//       IdleMutation<TData>() => idle(state),
//       LoadingMutation<TData>() => loading(state),
//       FailedMutation<TData>() => failed(state),
//       SuccessMutation<TData>() => success(state),
//     };
//   }
//
//   R maybeMap<R>({
//     R Function(IdleMutation<TData> state)? idle,
//     R Function(LoadingMutation<TData> state)? loading,
//     R Function(FailedMutation<TData> state)? failed,
//     R Function(SuccessMutation<TData> state)? success,
//     required R Function(MutationState<TData>) orElse,
//   }) {
//     return map(
//       idle: idle ?? orElse,
//       loading: loading ?? orElse,
//       failed: failed ?? orElse,
//       success: success ?? orElse,
//     );
//   }
//
//   R? mapOrNull<R>({
//     R Function(IdleMutation<TData> state)? idle,
//     R Function(LoadingMutation<TData> state)? loading,
//     R Function(FailedMutation<TData> state)? failed,
//     R Function(SuccessMutation<TData> state)? success,
//   }) {
//     R? orNull(_) => null;
//     return map(
//       idle: idle ?? orNull,
//       loading: loading ?? orNull,
//       failed: failed ?? orNull,
//       success: success ?? orNull,
//     );
//   }
//
//   R when<R>({
//     required R Function() idle,
//     required R Function() loading,
//     required R Function(Object error) failed,
//     required R Function(TData data) success,
//   }) {
//     return map(
//       idle: (state) => idle(),
//       loading: (state) => loading(),
//       failed: (state) => failed(state.error),
//       success: (state) => success(state.data),
//     );
//   }
//
//   R maybeWhen<R>({
//     R Function()? idle,
//     R Function()? loading,
//     R Function(Object error)? failed,
//     R Function(TData data)? success,
//     required R Function() orElse,
//   }) {
//     return map(
//       idle: (_) => idle == null ? orElse() : idle(),
//       loading: (_) => loading == null ? orElse() : loading(),
//       failed: (state) => failed == null ? orElse() : failed(state.error),
//       success: (state) => success == null ? orElse() : success(state.data),
//     );
//   }
//
//   R? whenOrNull<R>({
//     R Function()? idle,
//     R Function()? loading,
//     R Function(Object error)? failed,
//     R Function(TData data)? success,
//   }) {
//     return map(
//       idle: (_) => idle?.call(),
//       loading: (_) => loading?.call(),
//       failed: (state) => failed?.call(state.error),
//       success: (state) => success?.call(state.data),
//     );
//   }
// }
//
// class IdleMutation<TData> extends MutationState<TData> {
//   const IdleMutation() : super(args: const {});
//
//   @override
//   R map<R>({
//     required R Function(IdleMutation<TData> state) idle,
//     required R Function(LoadingMutation<TData> state) loading,
//     required R Function(FailedMutation<TData> state) failed,
//     required R Function(SuccessMutation<TData> state) success,
//   }) {
//     return idle(this);
//   }
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is IdleMutation<TData> &&
//           runtimeType == other.runtimeType &&
//           setEquals(args, other.args);
//
//   @override
//   int get hashCode => args.hashCode;
// }
//
// class LoadingMutation<TData> extends MutationState<TData> {
//   @override
//   final Map<Object?, double?> status;
//
//   const LoadingMutation({required super.args, required this.status});
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is LoadingMutation<TData> &&
//           runtimeType == other.runtimeType &&
//           setEquals(args, other.args) &&
//           mapEquals(status, other.status);
//
//   @override
//   int get hashCode => Object.hash(args, status);
// }
//
// class FailedMutation<TData> extends MutationState<TData> {
//   final Object error;
//
//   const FailedMutation({required super.args, required this.error});
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is FailedMutation<TData> &&
//           runtimeType == other.runtimeType &&
//           setEquals(args, other.args) &&
//           error == other.error;
//
//   @override
//   int get hashCode => Object.hash(args, error);
// }
//
// class SuccessMutation<TData> extends MutationState<TData> {
//   final TData data;
//
//   const SuccessMutation({required super.args, required this.data});
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is SuccessMutation<TData> &&
//           runtimeType == other.runtimeType &&
//           const DeepCollectionEquality().equals(data, other.data);
//
//   @override
//   int get hashCode => Object.hash(args, data);
// }
//
// class _MutationRef<TArg> extends MutationRef {
//   MutationNotifier? _notifier;
//   final TArg _arg;
//
//   final _subscriptions = <ProviderListenable, ProviderSubscription>{};
//
//   _MutationRef(super._container, this._notifier, this._arg);
//
//   @override
//   T read<T>(ProviderListenable<T> provider) {
//     _subscriptions.putIfAbsent(provider, () => _container.listen(provider, (_, _) {}));
//     return _container.read(provider);
//   }
//
//   @override
//   T refresh<T>(Refreshable<T> provider) {
//     _subscriptions.putIfAbsent(provider, () => _container.listen(provider, (_, _) {}));
//     return _container.refresh(provider);
//   }
//
//   @override
//   void updateProgress(double value) => _notifier?._updateProgress(_arg, value);
//
//   void dispose() {
//     for (final subscription in _subscriptions.values) {
//       subscription.close();
//     }
//     _notifier = null;
//   }
// }
''',
  );
}
