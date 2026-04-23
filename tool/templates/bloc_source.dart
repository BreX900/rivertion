// Version: 4.0.0

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
// ignore: implementation_imports
import 'package:rivertion/src/internals.dart';

extension SourceStateStreamableExtension<T> on StateStreamable<T> {
  SourceListenable<T> get source => _StateStreamableSourceListenable(this);
}

final class _StateStreamableSourceListenable<T> extends SourceListenable<T> {
  final StateStreamable<T> _stateStreamable;

  _StateStreamableSourceListenable(this._stateStreamable);

  @override
  SourceSubscription<T> listen(SourceListener<T> listener) {
    return SourceSubscription.viaAdapter(listener, (context) {
      context.state = _stateStreamable.state;
      final subscription = _stateStreamable.stream.listen((next) {
        context.state = next;
      });
      return subscription.cancel;
    });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _StateStreamableSourceListenable<T> &&
          runtimeType == other.runtimeType &&
          identical(_stateStreamable, other._stateStreamable);

  @override
  int get hashCode => _stateStreamable.hashCode;
}
