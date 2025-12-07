import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rivertion/src/internals/source_listenable_extension.dart';
import 'package:rivertion/src/internals/source_subscriptions.dart';
import 'package:rivertion/src/source.dart';

final class SourceSelector<T, R> extends _SourceTransformer<T, R> {
  final R Function(T state) _selector;

  SourceSelector(super._source, this._selector);

  @override
  R _select(T state) => _selector(state);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceSelector<T, R> &&
          runtimeType == other.runtimeType &&
          _source == other._source &&
          _selector == other._selector;

  @override
  int get hashCode => Object.hash(_source, _selector);
}

final class SourceArgSelector<T, R, A> extends _SourceTransformer<T, R> {
  final A _arg;
  final R Function(A arg, T value) _selector;

  SourceArgSelector(super._source, this._arg, this._selector);

  @override
  R _select(T state) => _selector(_arg, state);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceArgSelector<T, R, A> &&
          runtimeType == other.runtimeType &&
          _source == other._source &&
          _arg == other._arg &&
          _selector == other._selector;

  @override
  int get hashCode => Object.hash(_source, _arg, _selector);
}

@immutable
abstract base class _SourceTransformer<T, R> extends SourceListenable<R> {
  final Source<T> _source;

  _SourceTransformer(this._source);

  R _select(T state);

  @override
  SourceSubscription<R> listen(SourceListener<R> listener) {
    final subscription = _source.listenable.listen((previousState, currentState) {
      final previous = _select(previousState);
      final next = _select(currentState);
      if (previous == next) return;
      Zone.current.runBinaryGuarded(listener, previous, next);
    });
    return SourceSubscriptionBuilder(() => _select(subscription.read()), subscription.cancel);
  }
}
