import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rivertion/src/internals/source_listenable_extension.dart';
import 'package:rivertion/src/source.dart';

@immutable
final class FilterSourceListenable<T> extends SourceListenable<T> {
  final Source<T> _source;
  final bool Function(T previous, T next) _condition;

  FilterSourceListenable(this._source, this._condition);

  @override
  SourceSubscription<T> listen(SourceListener<T> listener) {
    return _source.listenable.listen((previous, next) {
      if (!_condition(previous, next)) return;
      Zone.current.runBinaryGuarded(listener, previous, next);
    });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterSourceListenable<T> &&
          runtimeType == other.runtimeType &&
          _source == other._source &&
          _condition == other._condition;

  @override
  int get hashCode => Object.hash(_source, _condition);
}
