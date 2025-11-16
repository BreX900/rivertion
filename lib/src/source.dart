import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rivertion/src/sources/source_filter.dart';
import 'package:rivertion/src/sources/source_selector.dart';

typedef SourceListener<T> = void Function(T previous, T state);

typedef SourceImmediatelyListener<T> = void Function(T? previous, T state);

sealed class Source<T> {}

mixin SourceContainer<T> implements Source<T> {
  SourceListenable<T> get source;
}

@immutable
abstract base class SourceListenable<T> implements Source<T> {
  SourceSubscription<T> listen(SourceListener<T> listener);

  SourceSubscription<T> listenImmediately(SourceImmediatelyListener<T> listener) {
    final subscription = listen(listener);
    Zone.current.runBinaryGuarded(listener, null, subscription.read());
    return subscription;
  }
}

extension SourceExtensions<T> on Source<T> {
  SourceListenable<R> select<R>(R Function(T state) selector) => SourceSelector(this, selector);

  SourceListenable<R> selectWith<R, A>(A arg, R Function(A arg, T state) selector) =>
      SourceArgSelector(this, arg, selector);

  SourceListenable<T> where(bool Function(T previous, T next) condition) =>
      SourceFilter(this, condition);
}

abstract base class SourceSubscription<T> {
  T read();

  void cancel();
}
