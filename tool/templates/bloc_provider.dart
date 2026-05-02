// Version: 4.0.0

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
// ignore: implementation_imports
import 'package:riverpod/src/internals.dart';

// ignore: invalid_use_of_internal_member
final _family = NotifierProviderFamily.internal((_) => throw UnimplementedError());

extension StateStremableProviderExtension<T> on StateStreamable<T> {
  ProviderListenable<T> get provider =>
      // ignore: invalid_use_of_internal_member
      NotifierProvider.internal(
        () => _StateStreamableNotifier(this),
        name: '$this',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
        retry: (_, _) => null,
        from: _family,
        argument: this,
      );
}

class _StateStreamableNotifier<T> extends Notifier<T> {
  final StateStreamable<T> stateStreamable;

  _StateStreamableNotifier(this.stateStreamable);

  @override
  T build() {
    final subscription = stateStreamable.stream.listen((state) => this.state = state);
    ref.onDispose(subscription.cancel);
    return stateStreamable.state;
  }
}
