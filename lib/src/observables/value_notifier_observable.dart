import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:riverpod/misc.dart';
import 'package:rivertion/src/observables/value_observable.dart';
import 'package:rivertion/src/providers/value_listenable_provider.dart';

extension ObservableValueNotifierExtension<T> on ValueNotifier<T> {
  ValueObservable<T> get observable => _ValueNotifierObservable(this);
}

class _ValueNotifierObservable<T> extends ValueObservable<T> {
  final ValueNotifier<T> _notifier;

  _ValueNotifierObservable(this._notifier);

  @override
  ProviderListenable<T> get provider => _notifier.provider;

  @override
  void Function() addListener(void Function(T state) listener, {required bool fireImmediately}) {
    void onChange() => listener(_notifier.value);
    _notifier.addListener(onChange);
    if (fireImmediately) Zone.current.runUnary(listener, _notifier.value);
    return () => _notifier.removeListener(onChange);
  }
}
