import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:rivertion/src/internals.dart';
import 'package:rivertion/src/source.dart';

class SourceNotifier<T> {
  final _listeners = LinkedList<_ListenersEntry<T>>();
  var _mounted = true;
  T _state;

  SourceNotifier(this._state);

  @protected
  bool get mounted => _mounted;

  Source<T> get source => _Source(this);

  @protected
  T get state {
    assert(_debugIsMounted());
    return _state;
  }

  @protected
  set state(T state) {
    assert(_debugIsMounted());

    final previousState = _state;
    _state = state;

    if (previousState == state) return;
    if (_listeners.isEmpty) return;

    _ListenersEntry<T>? currentEntry = _listeners.first;
    while (currentEntry != null) {
      final previousEntry = currentEntry;
      currentEntry = previousEntry.next;
      try {
        previousEntry.listener(previousState, state);
      } catch (error, stackTrace) {
        Zone.current.handleUncaughtError(error, stackTrace);
      }
    }
  }

  @mustCallSuper
  void dispose() {
    assert(_debugIsMounted());
    _listeners.clear();
    _mounted = false;
  }

  bool _debugIsMounted() {
    assert(
      _mounted,
      'Tried to use $runtimeType after `dispose` was called.\nConsider checking `mounted`.',
    );
    return true;
  }
}

class SourceController<T> extends SourceNotifier<T> {
  SourceController(super._state);

  @override
  T get state => super.state;

  @override
  set state(T state) => super.state = state;
}

class _Source<T> extends Source<T> {
  final SourceNotifier<T> _notifier;

  _Source(this._notifier);

  @override
  SourceSubscription<T> listen(SourceListener<T> listener) {
    assert(_notifier._debugIsMounted());
    final listenersEntry = _ListenersEntry(listener);
    _notifier._listeners.addFirst(listenersEntry);
    return _SourceSubscription(_notifier, listenersEntry);
  }

  @override
  bool operator ==(Object other) => other is _Source<T> && identical(_notifier, other._notifier);

  @override
  int get hashCode => _notifier.hashCode;
}

final class _ListenersEntry<T> extends LinkedListEntry<_ListenersEntry<T>> {
  final SourceListener<T> listener;

  _ListenersEntry(this.listener);
}

final class _SourceSubscription<T> extends SourceSubscriptionBase<T> {
  final SourceNotifier<T> _source;
  final _ListenersEntry<T> _listenersEntry;

  _SourceSubscription(this._source, this._listenersEntry);

  @override
  T onRead() => _source._state;

  @override
  void onCancel() => _listenersEntry.unlink();
}
