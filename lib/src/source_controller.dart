import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:rivertion/src/internals/source_subscriptions.dart';
import 'package:rivertion/src/source.dart';

class SourceNotifier<T> with SourceContainer<T> {
  final _listeners = LinkedList<_SourceSubscription<T>>();
  var _mounted = true;
  T _state;

  /// Initialize [state].
  SourceNotifier(this._state);

  /// Whether [dispose] was called or not.
  bool get mounted => _mounted;

  @override
  SourceListenable<T> get source => _SourceProxy(this);

  /// The current "state" of this [SourceNotifier].
  ///
  /// Updating this variable will synchronously call all the listeners.
  /// Notifying the listeners is O(N) with N the number of listeners.
  @protected
  @visibleForTesting
  T get state {
    assert(_debugIsMounted());
    return _state;
  }

  @protected
  @visibleForTesting
  set state(T state) {
    assert(_debugIsMounted());

    final previousState = _state;
    _state = state;

    if (previousState == state) return;
    if (_listeners.isEmpty) return;

    _SourceSubscription<T>? currentEntry = _listeners.first;
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

  /// If a listener has been added using [source] and hasn't been removed yet.
  bool get hasListeners {
    assert(_debugIsMounted(), '');
    return _listeners.isNotEmpty;
  }

  /// Frees all the resources associated with this object.
  ///
  /// This marks the object as no longer usable and will make all methods/properties
  /// besides [mounted] inaccessible.
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

  @override
  String toString() => '$runtimeType<$T>#${shortHash(hashCode)}($state)';
}

/// A [SourceController] that allows modifying its [state] from outside.
///
/// This avoids having to make a [SourceNotifier] subclass for simple scenarios.
class SourceController<T> extends SourceNotifier<T> {
  /// Initialize the state of [SourceController].
  SourceController(super._state);

  // Remove the protected status
  @override
  T get state => super.state;

  @override
  set state(T state) => super.state = state;

  /// Calls a function with the current [state] and assigns the result as the
  /// new state.
  T update(T Function(T state) updates) => state = updates(state);

  /// Equals to a [SourceController.state] setter
  void emit(T state) => this.state = state;

  @override
  String toString() => 'SourceController<$T>#${shortHash(hashCode)}($state)';
}

final class _SourceProxy<T> extends SourceListenable<T> {
  final SourceNotifier<T> _notifier;

  _SourceProxy(this._notifier);

  @override
  SourceSubscription<T> listen(SourceListener<T> listener) {
    assert(_notifier._debugIsMounted());
    final subscription = _SourceSubscription(_notifier, listener);
    _notifier._listeners.add(subscription);
    return subscription;
  }

  @override
  bool operator ==(Object other) =>
      other is _SourceProxy<T> && identical(_notifier, other._notifier);

  @override
  int get hashCode => _notifier.hashCode;
}

final class _SourceSubscription<T> extends LinkedListEntry<_SourceSubscription<T>>
    with SourceSubscriptionBase<T> {
  final SourceNotifier<T> _source;
  final SourceListener<T> listener;

  _SourceSubscription(this._source, this.listener);

  @override
  T onRead() => _source._state;

  @override
  void onCancel() {
    if (list == null) return;
    unlink();
  }
}
