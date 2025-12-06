import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rivertion/src/internals/source_listenable_extension.dart';
import 'package:rivertion/src/internals/source_subscriptions.dart';
import 'package:rivertion/src/source.dart';
import 'package:rivertion/src/source_widgets.dart';

/// The [Element] mixin for a [StatefulElement]
mixin SourceStatefulElementMixin on StatefulElement implements SourceRef {
  ValueListenable<bool>? _tickerNotifier;
  var _isDirty = false;
  final _listenerRemovers = <VoidCallback>[];
  var _dependencies = <Source<Object?>, SourceSubscription<Object?>>{};
  var _oldDependencies = <Source<Object?>, SourceSubscription<Object?>>{};
  final _onDisposeListeners = <VoidCallback>[];

  @override
  BuildContext get context => this;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _tickerNotifier = TickerMode.getNotifier(context);
    _tickerNotifier?.addListener(_onTickerModeChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tickerNotifier = TickerMode.getNotifier(context);
    if (_tickerNotifier != tickerNotifier) {
      _tickerNotifier?.removeListener(_onTickerModeChange);
      _tickerNotifier = tickerNotifier;
      _tickerNotifier?.addListener(_onTickerModeChange);
    }
  }

  @override
  void unmount() {
    super.unmount();

    for (final listenerRemover in _listenerRemovers) {
      listenerRemover();
    }
    _listenerRemovers.clear();
    for (final subscription in _dependencies.values) {
      subscription.cancel();
    }
    _dependencies = const {};
    for (final disposer in _onDisposeListeners) {
      disposer();
    }
  }

  @override
  T watchSource<T>(Source<T> source) {
    _assertNotDisposed();
    final subscription = _dependencies.putIfAbsent(source, () {
      return source.listenable.listen(_listenerForRebuild);
    });
    return subscription.read() as T;
  }

  @override
  void listenSource<T>(Source<T> source, SourceListener<T> listener) {
    _assertNotDisposed();
    _listenerRemovers.add(source.listenable.listen(listener).cancel);
  }

  @override
  SourceSubscription<T> listenSourceManual<T>(
    Source<T> source,
    void Function(T? previous, T state) listener, {
    bool fireImmediately = false,
  }) {
    _assertNotDisposed();
    final subscription = source.listenable.listen(listener);
    _onDisposeListeners.add(subscription.cancel);
    if (fireImmediately) Zone.current.runBinaryGuarded(listener, null, subscription.read());
    return SourceSubscriptionProxy(subscription, () {
      _onDisposeListeners.remove(subscription.cancel);
    });
  }

  @override
  void listenStream<T>(
    Stream<T> stream,
    void Function(T event) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function()? onDone,
  }) {
    _assertNotDisposed();
    _listenerRemovers.add(stream.listen(listener, onError: onError, onDone: onDone).cancel);
  }

  @override
  VoidCallback listenStreamManual<T>(
    Stream<T> stream,
    void Function(T event) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    void Function()? onDone,
  }) {
    _assertNotDisposed();
    final subscription = stream.listen(listener, onError: onError, onDone: onDone);
    _onDisposeListeners.add(subscription.cancel);
    return () {
      subscription.cancel();
      _onDisposeListeners.remove(onDispose);
    };
  }

  @override
  VoidCallback onDispose(VoidCallback onDispose) {
    _assertNotDisposed();
    _onDisposeListeners.add(onDispose);
    return () {
      onDispose();
      _onDisposeListeners.remove(onDispose);
    };
  }

  void _onTickerModeChange() {
    if (!(_tickerNotifier?.value ?? true)) return;
    if (_isDirty) markNeedsBuild();
    _isDirty = false;
  }

  void _listenerForRebuild(_, _) {
    if (_tickerNotifier?.value ?? true) {
      markNeedsBuild();
    } else {
      _isDirty = true;
    }
  }

  void _assertNotDisposed() {
    if (mounted) return;
    throw StateError('Cannot use "scope" after the widget was disposed.');
  }

  @override
  Widget build() {
    try {
      _oldDependencies = _dependencies;
      for (final listenerRemover in _listenerRemovers) {
        listenerRemover();
      }
      _listenerRemovers.clear();
      _dependencies = {};
      return super.build();
    } finally {
      for (final subscription in _oldDependencies.values) {
        subscription.cancel();
      }
      _oldDependencies = const {};
    }
  }
}
