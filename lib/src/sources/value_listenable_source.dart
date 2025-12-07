import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rivertion/src/internals/source_subscriptions.dart';
import 'package:rivertion/src/source.dart';

extension SourceValueListenablewExtension<T> on ValueListenable<T> {
  SourceListenable<T> get source => _ValueListenableSource(this);

  @Deprecated('Use source.select')
  SourceListenable<R> select<R>(R Function(T state) selector) => source.select(selector);

  @Deprecated('Use source.selectWith')
  SourceListenable<R> selectWith<R, A>(A arg, R Function(A arg, T state) selector) =>
      source.selectWith(arg, selector);

  @Deprecated('Use source.selectWhere')
  SourceListenable<T> where(bool Function(T previous, T next) condition) => source.where(condition);
}

final class _ValueListenableSource<T> extends SourceListenable<T> {
  final ValueListenable<T> _listenable;

  _ValueListenableSource(this._listenable);

  @override
  SourceSubscription<T> listen(SourceListener<T> listener) {
    var current = _listenable.value;
    void onChange() {
      final previous = current;
      current = _listenable.value;
      Zone.current.runBinaryGuarded(listener, previous, current);
    }

    _listenable.addListener(onChange);
    return SourceSubscriptionBuilder(() => current, () => _listenable.removeListener(onChange));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ValueListenableSource<T> &&
          runtimeType == other.runtimeType &&
          identical(_listenable, other._listenable);

  @override
  int get hashCode => _listenable.hashCode;
}
