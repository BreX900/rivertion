// Version: 4.0.0

import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
// ignore: implementation_imports
import 'package:rivertion/src/internals.dart';

extension SourceStateStreamableExtension<T> on StateStreamable<T> {
  SourceListenable<T> get source => _StateStreamableSource(this);
}

final class _StateStreamableSource<T> extends SourceListenable<T> {
  final StateStreamable<T> _stateStreamable;

  _StateStreamableSource(this._stateStreamable);

  @override
  SourceSubscription<T> listen(SourceListener<T> onChange) {
    var current = _stateStreamable.state;

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
          identical(_stateStreamable, other._stateStreamable);

  @override
  int get hashCode => _stateStreamable.hashCode;
}
