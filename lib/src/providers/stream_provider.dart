import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';

// ignore: invalid_use_of_internal_member
final _family = NotifierProviderFamily.internal((_) => throw UnimplementedError());

extension StreamProviderExtension<T> on Stream<T> {
  // ignore: invalid_use_of_internal_member
  ProviderListenable<AsyncValue<T>> get provider => NotifierProvider.internal(
    () => _AsyncStreamNotifier(this),
    name: '$this',
    dependencies: null,
    $allTransitiveDependencies: null,
    isAutoDispose: true,
    retry: (_, _) => null,
    from: _family,
    argument: this,
  );
}

class _AsyncStreamNotifier<T> extends Notifier<AsyncValue<T>> {
  final Stream<T> stream;

  _AsyncStreamNotifier(this.stream);

  @override
  AsyncValue<T> build() {
    final subscription = stream.listen(
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncError(error, stackTrace);
      },
      (event) {
        if (state == event) {
          ref.notifyListeners();
        } else {
          state = AsyncData(event);
        }
      },
    );
    ref.onDispose(subscription.cancel);

    return ref.isFirstBuild ? AsyncValue.loading() : state;
  }
}
