// ignore: implementation_imports
import 'package:riverpod/src/internals.dart';

// ignore: invalid_use_of_internal_member
final _family = NotifierProviderFamily.internal((_) => throw UnimplementedError());

extension StateNotifierProviderExtension<T> on StateNotifier<T> {
  // ignore: invalid_use_of_internal_member
  ProviderListenable<T> get provider => NotifierProvider.internal(
    () => _StateNotifierNotifier(this),
    name: '$this',
    dependencies: null,
    $allTransitiveDependencies: null,
    isAutoDispose: true,
    retry: (_, _) => null,
    from: _family,
    argument: this,
  );
}

class _StateNotifierNotifier<T> extends Notifier<T> {
  final StateNotifier<T> notifier;

  _StateNotifierNotifier(this.notifier);

  @override
  T build() {
    late final T initialState;
    ref.onDispose(
      notifier.addListener(fireImmediately: true, (state) {
        if (ref.isFirstBuild) {
          initialState = state;
        } else {
          this.state = state;
        }
      }),
    );
    return initialState;
  }
}
