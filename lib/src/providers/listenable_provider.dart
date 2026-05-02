import 'package:flutter/foundation.dart';
// ignore: implementation_imports
import 'package:riverpod/src/internals.dart';

// ignore: invalid_use_of_internal_member
final _family = NotifierProviderFamily.internal((_) => throw UnimplementedError());

extension ListenableProviderExtension<T extends Listenable> on T {
  ProviderListenable<T> get provider =>
      // ignore: invalid_use_of_internal_member
      NotifierProvider.internal(
        () => _ListenableNotifier(this),
        name: '$this',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
        retry: (_, _) => null,
        from: _family,
        argument: this,
      );
}

class _ListenableNotifier<T extends Listenable> extends Notifier<T> {
  final T listenable;

  _ListenableNotifier(this.listenable);

  @override
  T build() {
    listenable.addListener(ref.notifyListeners);
    ref.onDispose(ref.notifyListeners);
    return listenable;
  }
}
