// Version: 3.0.0

import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
// ignore: implementation_imports
import 'package:rivertion/src/internals.dart';

extension SourceStateStreamableExtension<T> on StateStreamable<T> {
  Source<T> get source => _StateStreamableSource(this);

  Source<R> select<R>(R Function(T state) selector) => source.select(selector);
  Source<R> selectWith<R, A>(A arg, R Function(A arg, T state) selector) =>
      source.selectWith(arg, selector);
}

final class _StateStreamableSource<T> extends Source<T> {
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

    return _StateStreamableSourceSubscription(() => current, streamSubscription);
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

final class _StateStreamableSourceSubscription<T> extends SourceSubscriptionBase<T> {
  final T Function() _reader;
  final StreamSubscription<T> _streamSubscription;

  _StateStreamableSourceSubscription(this._reader, this._streamSubscription);

  @override
  T onRead() => _reader();

  @override
  void onCancel() => unawaited(_streamSubscription.cancel());
}
