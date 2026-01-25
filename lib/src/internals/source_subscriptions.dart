import 'package:meta/meta.dart';
import 'package:rivertion/src/source.dart';

abstract base mixin class SourceSubscriptionBase<T> implements SourceSubscription<T> {
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

final class SourceSubscriptionBuilder<T> extends SourceSubscription<T> {
  final T Function() reader;
  final void Function() canceler;
  var _isCancelled = false;

  SourceSubscriptionBuilder(this.reader, this.canceler);

  @override
  T read() {
    assert(!_isCancelled, 'Tried to use $runtimeType after `cancel` was called.');
    return reader();
  }

  @override
  void cancel() {
    _isCancelled = true;
    canceler();
  }
}

@Deprecated('In favour of SourceSubscriptionBuilder')
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
