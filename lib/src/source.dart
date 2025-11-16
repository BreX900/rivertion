import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rivertion/src/sources/source_filter.dart';
import 'package:rivertion/src/sources/source_selector.dart';

typedef SourceListener<T> = void Function(T previous, T state);

typedef SourceImmediatelyListener<T> = void Function(T? previous, T state);

abstract interface class SourceProvider<T> {
  @internal
  Source<T> get source;
}

@immutable
abstract base class Source<T> implements SourceProvider<T> {
  @override
  Source<T> get source => this;

  SourceSubscription<T> listen(SourceListener<T> onChange);

  SourceSubscription<T> listenImmediately(SourceImmediatelyListener<T> listener) {
    final subscription = listen(listener);
    Zone.current.runBinaryGuarded(listener, null, subscription.read());
    return subscription;
  }

  Source<T> where(bool Function(T previous, T next) condition) => SourceFilter(this, condition);

  Source<R> select<R>(R Function(T state) selector) => SourceSelector(this, selector);

  Source<R> selectWith<R, A>(A arg, R Function(A arg, T state) selector) =>
      SourceArgSelector(this, arg, selector);
}

abstract base class SourceSubscription<T> {
  T read();

  void cancel();
}
