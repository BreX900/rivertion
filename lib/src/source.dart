import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rivertion/src/internals.dart';
import 'package:rivertion/src/sources/source_filter.dart';
import 'package:rivertion/src/sources/source_selector.dart';

typedef SourceListener<T> = void Function(T previous, T state);

typedef SourceImmediatelyListener<T> = void Function(T? previous, T state);

typedef SourceEquality = bool Function(Object? a, Object? b);

sealed class Source<T> {
  static SourceEquality equals = equalsDeep;

  static bool equalsDeep(Object? a, Object? b) {
    if (a is Set && b is Set) return setEquals(a, b);
    if (a is List && b is List) return listEquals(a, b);
    if (a is Map && b is Map) return mapEquals(a, b);
    return a == b;
  }
}

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

extension SourceListenableExtensions<T> on SourceListenable<T> {
  SourceListenable<R> select<R>(R Function(T state) selector) =>
      SelectorSourceListenable(this, selector);

  SourceListenable<R> selectWith<R, A>(A arg, R Function(A arg, T state) selector) =>
      ArgSelectorSourceListenable(this, arg, selector);

  SourceListenable<T> where(bool Function(T previous, T next) condition) =>
      FilterSourceListenable(this, condition);
}

abstract class AdapterSourceSubscriptionContext<T> {
  bool get isInitialized;

  T get state;

  set state(T state);
}

/// Represents the subscription to a [SourceListenable].
abstract mixin class SourceSubscription<T> {
  const SourceSubscription();

  factory SourceSubscription.viaAdapter(
    SourceListener<T> lister,
    void Function() Function(AdapterSourceSubscriptionContext context) initializer,
  ) = AdapterSourceSubscription<T>;

  /// Whether the subscription is paused.
  ///
  /// {@template rivertion.pause}
  /// Upon resuming the subscription, if any event was sent while paused,
  /// the last event will be sent to the listener.
  /// {@endtemplate}
  bool get isPaused;

  /// Obtain the latest value emitted by the source.
  ///
  /// This method throws if [closed] is true.
  T read();

  /// Pauses the subscription.
  ///
  /// {@macro rivertion.pause}
  void pause();

  /// Resumes the subscription.
  ///
  /// {@macro rivertion.pause}
  void resume();

  /// Cancels listening to the source.
  ///
  /// It is safe to call this method multiple times.
  void cancel();
}
