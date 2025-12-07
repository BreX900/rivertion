import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rivertion/src/internals/source_subscriptions.dart';
import 'package:rivertion/src/source.dart';

extension SourceListenableExtension<T extends Listenable> on T {
  SourceListenable<R> sourceBy<R>(R Function(T listenable) selector) =>
      _ListenableSource(this, selector);
}

final class _ListenableSource<T extends Listenable, R> extends SourceListenable<R> {
  final T _listenable;
  final R Function(T listenable) _selector;

  _ListenableSource(this._listenable, this._selector);

  @override
  SourceSubscription<R> listen(SourceListener<R> listener) {
    var current = _selector(_listenable);
    assert(current != _listenable, 'Do not return the $T but select its value/property/field.');
    void onChange() {
      final previous = current;
      current = _selector(_listenable);
      if (previous == current) return;
      Zone.current.runBinaryGuarded(listener, previous, current);
    }

    _listenable.addListener(onChange);
    return SourceSubscriptionBuilder(() => current, () => _listenable.removeListener(onChange));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ListenableSource<T, R> &&
          runtimeType == other.runtimeType &&
          identical(_listenable, other._listenable) &&
          _selector == other._selector;

  @override
  int get hashCode => Object.hash(_listenable, _selector);
}
