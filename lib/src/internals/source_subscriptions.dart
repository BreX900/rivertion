import 'package:meta/meta.dart';
import 'package:rivertion/src/source.dart';

abstract base class SourceSubscriptionBase<T> extends SourceSubscription<T> {
  var _isCancelled = false;

  @protected
  T onRead();

  @protected
  void onCancel();

  @override
  T read() {
    _debugIsCancelled();
    return onRead();
  }

  @override
  void cancel() {
    _debugIsCancelled();
    onCancel();
    _isCancelled = true;
  }

  bool _debugIsCancelled() {
    assert(!_isCancelled, 'Tried to use $runtimeType after `cancel` was called.');
    return true;
  }
}

final class SourceSubscriptionProxy<T> extends SourceSubscription<T> {
  final SourceSubscription<T> proxy;
  final void Function() onCancel;

  SourceSubscriptionProxy(this.proxy, this.onCancel);

  @override
  void cancel() {
    proxy.cancel();
    onCancel();
  }

  @override
  T read() => proxy.read();
}
