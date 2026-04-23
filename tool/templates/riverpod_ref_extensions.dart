import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: implementation_imports
import 'package:rivertion/src/internals.dart';

extension SourcesRefExtension on Ref {
  T watchSource<T>(Source<T> source) {
    final subscription = source.listenable.listen((_, _) => invalidateSelf(asReload: true));
    onDispose(subscription.cancel);
    return subscription.read();
  }

  SourceSubscription<T> listenSource<T>(Source<T> source, SourceListener<T> listener) {
    final subscription = source.listenable.listen(listener);
    final dispositionRemover = onDispose(subscription.cancel);
    return _RefSourceSubscription(subscription, dispositionRemover);
  }

  SourceSubscription<T> listenSourceImmediately<T>(
    Source<T> source,
    SourceImmediatelyListener<T> listener,
  ) {
    final subscription = source.listenable.listenImmediately(listener);
    final dispositionRemover = onDispose(subscription.cancel);
    return _RefSourceSubscription(subscription, dispositionRemover);
  }
}

class _RefSourceSubscription<T> extends ProxySourceSubscription<T> {
  final void Function() _dispositionRemover;

  _RefSourceSubscription(super.subscription, this._dispositionRemover);

  @override
  void cancel() {
    super.cancel();
    _dispositionRemover();
  }
}
