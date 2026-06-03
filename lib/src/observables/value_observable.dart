import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';

abstract class ValueObservable<T> {
  ProviderListenable<T> get provider;

  void Function() addListener(void Function(T state) listener, {required bool fireImmediately});

  void Function() listen(void Function(T previous, T state) listener) {
    var hasCurrent = false;
    late T current;
    return addListener(fireImmediately: true, (next) {
      if (hasCurrent) {
        final previous = current;
        current = next;

        if (previous != next) listener(previous, next);
      } else {
        hasCurrent = true;
        current = next;
      }
    });
  }

  void Function() listenImmediately(void Function(T? previous, T state) listener) {
    var hasCurrent = false;
    late T current;
    return addListener(fireImmediately: true, (next) {
      if (hasCurrent) {
        final previous = current;
        current = next;

        if (previous != next) listener(previous, next);
      } else {
        current = next;
        hasCurrent = true;

        listener(null, next);
      }
    });
  }

  ValueObservable<R> select<R>(R Function(T state) selector) =>
      _ValueObservableSelector(this, selector);
}

class _ValueObservableSelector<T, R> extends ValueObservable<R> {
  final ValueObservable<T> _observable;
  final R Function(T state) _selector;

  _ValueObservableSelector(this._observable, this._selector);

  @override
  ProviderListenable<R> get provider => _observable.provider.select(_selector);

  @override
  void Function() addListener(void Function(R state) listener, {required bool fireImmediately}) =>
      _observable.addListener(
        fireImmediately: fireImmediately,
        (state) => listener(_selector(state)),
      );
}

extension<T> on (T,) {
  T get value => $1;
}
