import 'package:riverpod/legacy.dart';
import 'package:riverpod/misc.dart';
import 'package:rivertion/src/observables/value_observable.dart';
import 'package:rivertion/src/providers/state_notifier_provider.dart';

extension ObservableStateNotifierExtension<T> on StateNotifier<T> {
  ValueObservable<T> get observable => _StateNotifierObservable(this);
}

class _StateNotifierObservable<T> extends ValueObservable<T> {
  final StateNotifier<T> _notifier;

  _StateNotifierObservable(this._notifier);

  @override
  ProviderListenable<T> get provider => _notifier.provider;

  @override
  void Function() addListener(void Function(T state) listener, {required bool fireImmediately}) =>
      _notifier.addListener(fireImmediately: fireImmediately, listener);
}
