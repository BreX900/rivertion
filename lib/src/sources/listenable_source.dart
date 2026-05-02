import 'package:flutter/foundation.dart';
import 'package:rivertion/src/source.dart';

extension SourceListenableExtension<T extends Listenable> on T {
  @Deprecated('In favour of Listenable.provider extension')
  SourceListenable<R> sourceBy<R>(R Function(T listenable) selector) =>
      _ListenableSourceListenable(this, selector);
}

final class _ListenableSourceListenable<T extends Listenable, R> extends SourceListenable<R> {
  final T _listenable;
  final R Function(T listenable) _selector;

  _ListenableSourceListenable(this._listenable, this._selector);

  @override
  SourceSubscription<R> listen(SourceListener<R> listener) {
    return SourceSubscription.viaAdapter(listener, (context) {
      context.state = _selector(_listenable);

      void onChange() {
        final next = _selector(_listenable);
        if (Source.equalsDeep(context.state, next)) return;
        context.state = next;
      }

      _listenable.addListener(onChange);
      return () => _listenable.removeListener(onChange);
    });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ListenableSourceListenable<T, R> &&
          runtimeType == other.runtimeType &&
          identical(_listenable, other._listenable) &&
          _selector == other._selector;

  @override
  int get hashCode => Object.hash(_listenable, _selector);
}
