import 'package:flutter/foundation.dart';
// ignore: implementation_imports
import 'package:riverpod/src/internals.dart';

// ignore: invalid_use_of_internal_member
final _family = NotifierProviderFamily.internal((_) => throw UnimplementedError());

extension ValueListenableProviderExtension<TListenable extends ValueListenable<T>, T>
    on TListenable {
  // ignore: invalid_use_of_internal_member
  ProviderListenable<T> get provider => NotifierProvider.internal(
    () => _ValueListenableNotifier(this),
    name: '$this',
    dependencies: null,
    $allTransitiveDependencies: null,
    isAutoDispose: true,
    retry: (_, _) => null,
    from: _family,
    argument: this,
  );
}

class _ValueListenableNotifier<T> extends Notifier<T> {
  final ValueListenable<T> listenable;

  _ValueListenableNotifier(this.listenable);

  @override
  T build() {
    void listener() => state = listenable.value;
    listenable.addListener(listener);
    ref.onDispose(() => listenable.removeListener(listener));
    return listenable.value;
  }
}
