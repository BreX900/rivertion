import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rivertion/src/source.dart';

mixin SourceSubscriptionDebuggable<T> on SourceSubscription<T> {
  var _isCancelled = false;

  @override
  @mustCallSuper
  void cancel() {
    _isCancelled = true;
  }

  @protected
  bool debugIsCancelled() {
    assert(!_isCancelled, 'Tried to use $runtimeType after `cancel` was called.');
    return true;
  }
}

abstract class ProxySourceSubscription<T> implements SourceSubscription<T> {
  final SourceSubscription<T> subscription;

  ProxySourceSubscription(this.subscription);

  @override
  @mustCallSuper
  bool get isPaused => subscription.isPaused;

  @override
  @mustCallSuper
  T read() => subscription.read();

  @override
  @mustCallSuper
  void pause() => subscription.pause();

  @override
  @mustCallSuper
  void resume() => subscription.resume();

  @override
  @mustCallSuper
  void cancel() => subscription.cancel();
}

@internal
class AdapterSourceSubscription<T> extends SourceSubscription<T>
    with SourceSubscriptionDebuggable<T>
    implements AdapterSourceSubscriptionContext<T> {
  final void Function(T previous, T current) _listener;
  late final void Function() _disposer;
  var _isInitialized = false;
  late T _current;
  var _isPaused = false;
  (T previous, T next)? _pausedState;

  AdapterSourceSubscription(
    void Function(T previous, T current) listener,
    void Function() Function(AdapterSourceSubscriptionContext<T> context) initializer,
  ) : _listener = listener {
    _disposer = initializer(this);
    assert(_isInitialized, 'Please call the "context.state" setter during initialization!');
  }

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isPaused => _isPaused;

  @override
  T get state {
    debugIsCancelled();

    return _current;
  }

  @override
  set state(T state) {
    debugIsCancelled();

    if (!_isInitialized) {
      _isInitialized = true;
      _current = state;
      return;
    }

    final previous = _current;
    _current = state;

    if (_isPaused) {
      _pausedState ??= (previous, _current);
    } else {
      Zone.current.runBinaryGuarded(_listener, previous, _current);
    }
  }

  @override
  T read() {
    debugIsCancelled();
    return _current;
  }

  @override
  void pause() {
    debugIsCancelled();
    _isPaused = true;
  }

  @override
  void resume() {
    debugIsCancelled();
    _isPaused = false;
    if (_pausedState case (T previous, T current)) {
      _pausedState = null;
      Zone.current.runBinaryGuarded(_listener, previous, current);
    }
  }

  @override
  void cancel() {
    super.cancel();
    _pausedState = null;
    _disposer();
  }
}
