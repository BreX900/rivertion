import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rivertion/src/internals.dart';
import 'package:rivertion/src/source.dart';
import 'package:rivertion/src/sources/source_selector.dart';

extension SourceListenableExtension<T extends Listenable> on T {
  Source<R> sourceBy<R>(R Function(T listenable) selector) => _ListenableSource(this, selector);
}

extension SourceValueListenableExtension<T> on ValueListenable<T> {
  Source<T> get source => _ListenableSource(this, _selectValue);

  Source<R> select<R>(R Function(T state) selector) => source.select(selector);
  Source<R> selectWith<R, A>(A arg, R Function(A arg, T state) selector) =>
      source.selectWith(arg, selector);

  static T _selectValue<T>(ValueListenable<T> listenable) => listenable.value;
}

class _ListenableSource<T extends Listenable, R> extends Source<R> {
  final T listenable;
  final R Function(T listenable) selector;

  _ListenableSource(this.listenable, this.selector);

  @override
  SourceSubscription<R> listen(SourceListener<R> listener) {
    var current = selector(listenable);
    void onChange() {
      final previous = current;
      current = selector(listenable);
      if (previous == current) return;
      Zone.current.runBinaryGuarded(listener, previous, current);
    }

    listenable.addListener(onChange);
    return _ListenableSubscription(listenable, onChange, () => current);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ListenableSource &&
          runtimeType == other.runtimeType &&
          identical(listenable, other.listenable) &&
          selector == other.selector;

  @override
  int get hashCode => Object.hash(listenable, selector);
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
