// Version: 3.0.0

import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
// ignore: implementation_imports
import 'package:rivertion/src/internals.dart';

extension SourceStateStreamableExtension<T> on StateStreamable<T> {
  SourceListenable<T> get source => _StateStreamableSource(this);

  @Deprecated('In favour of source.select')
  SourceListenable<R> select<R>(R Function(T state) selector) => source.select(selector);

  @Deprecated('In favour of source.selectWith')
  SourceListenable<R> selectWith<R, A>(A arg, R Function(A arg, T state) selector) =>
      source.selectWith(arg, selector);

  @Deprecated('In favour of source.where')
  SourceListenable<T> where(bool Function(T previous, T next) condition) => source.where(condition);
}

final class _StateStreamableSource<T> extends SourceListenable<T> {
  final StateStreamable<T> _stateStreamable;

  _StateStreamableSource(this._stateStreamable);

  @override
  SourceSubscription<T> listen(SourceListener<T> onChange) {
    var current = _stateStreamable.state;

    // ignore: cancel_subscriptions
    final streamSubscription = _stateStreamable.stream.listen((next) {
      final previous = current;
      current = next;
      Zone.current.runBinaryGuarded(onChange, previous, next);
    });

    return SourceSubscriptionBuilder(() => current, streamSubscription.cancel);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _StateStreamableSource<T> &&
          runtimeType == other.runtimeType &&
          _stateStreamable == other._stateStreamable;

  @override
  int get hashCode => _stateStreamable.hashCode;
}
