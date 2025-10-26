import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rivertion/src/internals.dart';
import 'package:rivertion/src/source.dart';

extension SelectSourceExtension<T> on Source<T> {
  Source<R> select<R>(R Function(T state) selector) => _SourceSelector(this, selector);

  Source<R> selectWith<R, A>(A arg, R Function(A arg, T state) selector) =>
      _SourceArgSelector(this, arg, selector);
}

final class _SourceSelector<T, R> extends _SourceTransformer<T, R> {
  final R Function(T state) selector;

  _SourceSelector(super.source, this.selector);

  @override
  R select(T state) => selector(state);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SourceArgSelector &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          selector == other.selector;

  @override
  int get hashCode => Object.hash(source, selector);
}

final class _SourceArgSelector<T, R, A> extends _SourceTransformer<T, R> {
  final A arg;
  final R Function(A arg, T value) selector;

  _SourceArgSelector(super.source, this.arg, this.selector);

  @override
  R select(T state) => selector(arg, state);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SourceArgSelector &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          arg == other.arg &&
          selector == other.selector;

  @override
  int get hashCode => Object.hash(source, arg, selector);
}

@immutable
abstract base class _SourceTransformer<T, R> extends Source<R> {
  final Source<T> source;

  _SourceTransformer(this.source);

  R select(T state);

  @override
  SourceSubscription<R> listen(SourceListener<R> listener) {
    _Optional<R>? current;
    final subscription = source.listen((previousState, currentState) {
      final previous = current ?? _Optional(select(previousState));
      final next = _Optional(select(currentState));
      current = next;
      if (previous.value == next.value) return;
      Zone.current.runBinaryGuarded(listener, previous.value, next.value);
    });
    return _SourceTransformerSubscription(subscription, () {
      return (current ??= _Optional(select(subscription.read()))).value;
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
