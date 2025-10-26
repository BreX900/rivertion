import 'dart:async';

import 'package:meta/meta.dart';

typedef SourceListener<T> = void Function(T previous, T state);

typedef SourceImmediatelyListener<T> = void Function(T? previous, T state);

@immutable
abstract class Source<T> {
  SourceSubscription<T> listen(SourceListener<T> onChange);

  SourceSubscription<T> listenImmediately(SourceImmediatelyListener<T> listener) {
    final subscription = listen(listener);
    Zone.current.runBinaryGuarded(listener, null, subscription.read());
    return subscription;
  }
}

abstract base class SourceSubscription<T> {
  T read();

  void cancel();
}
