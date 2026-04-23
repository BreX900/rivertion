import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rivertion/src/internals/source_listenable_extension.dart';
import 'package:rivertion/src/source.dart';

final class SelectorSourceListenable<T, R> extends _TransformerSourceListenable<T, R> {
  final R Function(T state) _selector;

  SelectorSourceListenable(super._source, this._selector);

  @override
  R _select(T state) => _selector(state);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectorSourceListenable<T, R> &&
          runtimeType == other.runtimeType &&
          _source == other._source &&
          _selector == other._selector;

  @override
  int get hashCode => Object.hash(_source, _selector);
}

final class ArgSelectorSourceListenable<T, R, A> extends _TransformerSourceListenable<T, R> {
  final A _arg;
  final R Function(A arg, T value) _selector;

  ArgSelectorSourceListenable(super._source, this._arg, this._selector);

  @override
  R _select(T state) => _selector(_arg, state);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArgSelectorSourceListenable<T, R, A> &&
          runtimeType == other.runtimeType &&
          _source == other._source &&
          _arg == other._arg &&
          _selector == other._selector;

  @override
  int get hashCode => Object.hash(_source, _arg, _selector);
}

@immutable
abstract base class _TransformerSourceListenable<T, R> extends SourceListenable<R> {
  final Source<T> _source;

  _TransformerSourceListenable(this._source);

  R _select(T state);

  @override
  SourceSubscription<R> listen(SourceListener<R> listener) {
    return TransformerSourceSubscription<T, R>(
      (subscription) => _select(subscription.read()),
      _source.listenable.listen((previousState, currentState) {
        final previous = _select(previousState);
        final next = _select(currentState);
        if (Source.equals(previous, next)) return;
        Zone.current.runBinaryGuarded(listener, previous, next);
      }),
    );
  }
}

class TransformerSourceSubscription<T, R> implements SourceSubscription<R> {
  final SourceSubscription<T> _subscription;
  final R Function(SourceSubscription<T> subscription) _reader;

  TransformerSourceSubscription(this._reader, this._subscription);

  @override
  @mustCallSuper
  bool get isPaused => _subscription.isPaused;

  @override
  R read() => _reader(_subscription);

  @override
  @mustCallSuper
  void pause() => _subscription.pause();

  @override
  @mustCallSuper
  void resume() => _subscription.resume();

  @override
  @mustCallSuper
  void cancel() => _subscription.cancel();
}
