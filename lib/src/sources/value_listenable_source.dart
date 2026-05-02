import 'package:flutter/foundation.dart';
import 'package:rivertion/src/source.dart';

extension SourceValueListenablewExtension<T> on ValueListenable<T> {
  @Deprecated('In favour of ValueListenable.provider extension')
  SourceListenable<T> get source => _ValueSourceListenable(this);
}

final class _ValueSourceListenable<T> extends SourceListenable<T> {
  final ValueListenable<T> _listenable;

  _ValueSourceListenable(this._listenable);

  @override
  SourceSubscription<T> listen(SourceListener<T> listener) {
    return SourceSubscription.viaAdapter(listener, (context) {
      context.state = _listenable.value;

      void onChange() => context.state = _listenable.value;
      _listenable.addListener(onChange);
      return () => _listenable.removeListener(onChange);
    });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ValueSourceListenable<T> &&
          runtimeType == other.runtimeType &&
          identical(_listenable, other._listenable);

  @override
  int get hashCode => _listenable.hashCode;
}
