import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rivertion/src/internals.dart';
import 'package:rivertion/src/source.dart';

final class SourceSelector<T, R> extends _SourceTransformer<T, R> {
  final R Function(T state) selector;

  SourceSelector(super.source, this.selector);

  @override
  R _select(T state) => selector(state);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceArgSelector &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          selector == other.selector;

  @override
  int get hashCode => Object.hash(source, selector);
}

final class SourceArgSelector<T, R, A> extends _SourceTransformer<T, R> {
  final A arg;
  final R Function(A arg, T value) selector;

  SourceArgSelector(super.source, this.arg, this.selector);

  @override
  R _select(T state) => selector(arg, state);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceArgSelector &&
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

  R _select(T state);

  @override
  SourceSubscription<R> listen(SourceListener<R> listener) {
    _Optional<R>? current;
    final subscription = source.listen((previousState, currentState) {
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
