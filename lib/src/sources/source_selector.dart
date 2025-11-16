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
    _Optional<R>? current;
    final subscription = _source.listenable.listen((previousState, currentState) {
      final previous = current ?? _Optional(_select(previousState));
      final next = _Optional(_select(currentState));
      current = next;
      if (previous.value == next.value) return;
      Zone.current.runBinaryGuarded(listener, previous.value, next.value);
    });
    return _SourceTransformerSubscription(subscription, () {
      return (current ??= _Optional(_select(subscription.read()))).value;
    });
  }
}

class _Optional<T> {
  final T value;

  _Optional(this.value);
}

final class _SourceTransformerSubscription<T, R> extends SourceSubscriptionBase<R> {
  final SourceSubscription<T> subscription;
  final R Function() reader;

  _SourceTransformerSubscription(this.subscription, this.reader);

  @override
  R onRead() => reader();

  @override
  void onCancel() => subscription.cancel();
}
