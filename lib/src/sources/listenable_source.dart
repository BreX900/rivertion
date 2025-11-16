import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rivertion/src/internals/source_subscriptions.dart';
import 'package:rivertion/src/source.dart';

extension SourceListenableExtension<T extends Listenable> on T {
  SourceListenable<R> sourceBy<R>(R Function(T listenable) selector) =>
      _ListenableSource(this, selector);
}

extension SourceValueListenablewExtension<T> on ValueListenable<T> {
  SourceListenable<T> get source => _ListenableSource(this, _selectValue);

  SourceListenable<R> select<R>(R Function(T state) selector) => source.select(selector);

  SourceListenable<R> selectWith<R, A>(A arg, R Function(A arg, T state) selector) =>
      source.selectWith(arg, selector);

  SourceListenable<T> where(bool Function(T previous, T next) condition) => source.where(condition);

  static T _selectValue<T>(ValueListenable<T> listenable) => listenable.value;
}

final class _ListenableSource<T extends Listenable, R> extends SourceListenable<R> {
  final T _listenable;
  final R Function(T listenable) _selector;

  _ListenableSource(this._listenable, this._selector);

  @override
  SourceSubscription<R> listen(SourceListener<R> listener) {
    var current = _selector(_listenable);
    void onChange() {
      final previous = current;
      current = _selector(_listenable);
      if (previous == current) return;
      Zone.current.runBinaryGuarded(listener, previous, current);
    }

    _listenable.addListener(onChange);
    return _ListenableSubscription(_listenable, onChange, () => current);
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

final class _ListenableSubscription<T extends Listenable, R> extends SourceSubscriptionBase<R> {
  final T listenable;
  final VoidCallback listener;
  final ValueGetter<R> reader;

  _ListenableSubscription(this.listenable, this.listener, this.reader);

  @override
  R onRead() => reader();

  @override
  void onCancel() => listenable.removeListener(listener);
}
