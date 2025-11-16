import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rivertion/src/source.dart';

@immutable
final class SourceFilter<T> extends Source<T> {
  @override
  final Source<T> source;
  final bool Function(T previous, T next) condition;

  SourceFilter(this.source, this.condition);

  @override
  SourceSubscription<T> listen(SourceListener<T> listener) {
    return source.listen((previous, next) {
      if (!condition(previous, next)) return;
      Zone.current.runBinaryGuarded(listener, previous, next);
    });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceFilter<T> &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          condition == other.condition;

  @override
  int get hashCode => Object.hash(source, condition);
}
