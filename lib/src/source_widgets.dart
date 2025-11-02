import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:rivertion/src/internals.dart';
import 'package:rivertion/src/source.dart';

base class SourceScope {
  final SourceStatefulElementMixin _element;

  /// The [BuildContext] of the widget associated to this [WidgetRef].
  ///
  /// This is strictly identical to the [BuildContext] passed to [ConsumerWidget.build].
  BuildContext get context => _element;

  @internal
  SourceScope(this._element);

  /// Returns the value exposed by a source and rebuild the widget when that
  /// value changes.
  ///
  /// This method should only be used at the "root" of the `build` method of a widget.
  ///
  /// **Good**: Use [watch] inside the `build` method.
  /// ```dart
  /// class Example extends SourceWidget {
  ///   @override
  ///   Widget build(BuildContext context, SourceScope scope) {
  ///     // Correct, we are inside the build method and at its root.
  ///     final count = scope.watch(counterSource);
  ///   }
  /// }
  /// ```
  /// **Good**: It is accepted to use [watch] at the root of "builders" too.
  /// ```dart
  /// class Example extends SourceWidget {
  ///   @override
  ///   Widget build(BuildContext context, SourceScope scope) {
  ///     return ListView.builder(
  ///       itemBuilder: (context) {
  ///          // This is accepted, as we are at the root of a "builder"
  ///          final count = scope.watch(counterSource);
  ///       },
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// **Bad**: Don't use [watch] outside of the `build` method.
  /// ```dart
  /// class Example extends SourceStatefulWidget {
  ///   @override
  ///   ExampleState createState() => ExampleState();
  /// }
  ///
  /// class ExampleState extends SourceState<Example> {
  ///   @override
  ///   void initState() {
  ///     super.initState();
  ///     // Incorrect, we are not inside the build method.
  ///     final count = scope.watch(counterSource);
  ///   }
  /// }
  /// ```
  ///
  /// **Bad**: Don't use [watch] inside event handles withing `build` method.
  /// ```dart
  /// class Example extends ConsumerWidget {
  ///   @override
  ///   Widget build(BuildContext context, SourceScope scope) {
  ///     return ElevatedButton(
  ///       onTap: () {
  ///         // Incorrect, we are inside the build method, but neither at its
  ///         // root, nor inside a "builder".
  ///         final count = scope.watch(counterSource);
  ///       }
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// - [Source.select], which allows a widget to filter rebuilds by
  ///   observing only the selected properties.
  /// - [listen], to react to changes on a source, such as for showing modals.
  T watch<T>(Source<T> source) {
    _assertNotDisposed();
    return _element._watch(source);
  }

  /// Listen to a source and call `listener` whenever its value changes,
  /// without having to take care of removing the listener.
  ///
  /// The [listen] method should exclusively be used at the root of the `build`:
  ///
  /// **Good**: Use [listen] inside the `build` method.
  /// ```dart
  /// class Example extends SourceWidget {
  ///   @override
  ///   Widget build(BuildContext context, SourceScope scope) {
  ///     // Correct, we are inside the build method and at its root.
  ///     scope.listen(counterSource, (prev, next) {});
  ///   }
  /// }
  /// ```
  ///
  /// **Bad**: Do not use [listen] inside builders.
  /// ```dart
  /// class Example extends SourceWidget {
  ///   @override
  ///   Widget build(BuildContext context, SourceScope scope) {
  ///     return ListView.builder(
  ///       itemBuilder: (context) {
  ///          // This is accepted, as we are at the root of a "builder"
  ///          scope.listen(counterSource, (prev, next) {});
  ///       },
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// **Bad**: Don't use [listen] outside of the `build` method.
  /// ```dart
  /// class Example extends SourceStatefulWidget {
  ///   @override
  ///   ExampleState createState() => ExampleState();
  /// }
  ///
  /// class ExampleState extends SourceState<Example> {
  ///   @override
  ///   void initState() {
  ///     super.initState();
  ///     // Incorrect, we are not inside the build method.
  ///     scope.listen(counterSource, (prev, next) {});
  ///   }
  /// }
  /// ```
  ///
  /// **Bad**: Don't use [listen] inside event handles withing `build` method.
  /// ```dart
  /// class Example extends SourceWidget {
  ///   @override
  ///   Widget build(BuildContext context, SourceScope scope) {
  ///     return ElevatedButton(
  ///       onTap: () {
  ///         // Incorrect, we are inside the build method, but neither at its
  ///         // root, nor inside a "builder".
  ///         scope.listen(counterSource, (prev, next) {});
  ///       }
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// **Note**:
  /// Listeners will automatically be removed if a widget rebuilds and stops
  /// listening to a provider.
  ///
  /// See also:
  /// - [listenManual], for listening to a provider from outside `build`.
  /// - [watch], to listen to providers in a declarative manner.
  /// - [read], to read a provider without listening to it.
  ///
  /// This is useful for showing modals or other imperative logic.
  void listen<T>(Source<T> source, SourceListener<T> listener) {
    _assertNotDisposed();
    _element._listen(source, listener);
  }

  /// Listen to a source and call `listener` whenever its value changes.
  ///
  /// As opposed to [listen], [listenManual] is not safe to use within the `build`
  /// method of a widget.
  /// Instead, [listenManual] is designed to be used inside [State.initState] or
  /// other [State] life-cycles.
  ///
  /// [listenManual] returns a [SourceSubscription] which can be used to stop
  /// listening to the source, or to read the current value exposed by
  /// the source.
  ///
  /// It is not necessary to call [SourceSubscription.cancel] inside [State.dispose].
  /// When the widget that calls [listenManual] is disposed, the subscription
  /// will be disposed automatically.
  SourceSubscription<T> listenManual<T>(
    Source<T> source,
    void Function(T? previous, T state) listener, {
    bool fireImmediately = false,
  }) {
    _assertNotDisposed();
    return _element._listenManual(source, listener, fireImmediately: fireImmediately);
  }

  void subscribe<T>(Stream<T> stream, void Function(T event) listener) {
    _assertNotDisposed();
    _element._subscribe(stream, listener);
  }

  VoidCallback subscribeManual<T>(Stream<T> stream, void Function(T event) listener) {
    _assertNotDisposed();
    return _element._subscribeManual(stream, listener);
  }

  VoidCallback onDispose(VoidCallback onDispose) {
    _assertNotDisposed();
    return _element._onDispose(onDispose);
  }

  void _assertNotDisposed() {
    if (_element.mounted) return;
    throw StateError('Cannot use "scope" after the widget was disposed.');
  }
}

class SourceBuilder extends SourceWidget {
  final Widget Function(BuildContext context, SourceScope scope, Widget? child) builder;

  const SourceBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context, SourceScope scope) => builder(context, scope, null);
}

abstract class SourceWidget extends SourceStatefulWidget {
  const SourceWidget({super.key});

  Widget build(BuildContext context, SourceScope scope);

  @override
  SourceState<SourceStatefulWidget> createState() => _SourceState();
}

class _SourceState extends SourceState<SourceWidget> {
  @override
  Widget build(BuildContext context) => widget.build(context, scope);
}

/// A [StatefulWidget] that has a [State] capable of reading sources.
///
/// This is used exactly like a [StatefulWidget], but with a [State] that must
/// subclass [SourceState] :
///
/// ```dart
/// class MySource extends SourceStatefulWidget {
///  const MySource({Key? key}): super(key: key);
///
///   @override
///   SourceState<MySource> createState() => _MySourceState();
/// }
///
/// class _MySourceState extends SourceState<MySource> {
///   @override
///   void initState() {
///     // All State life-cycles can be used
///     super.initState();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     // "source" is a property of SourceState and can be used to read providers
///     source.watch(someSource);
///   }
/// }
/// ```
abstract class SourceStatefulWidget extends StatefulWidget {
  const SourceStatefulWidget({super.key});

  @override
  SourceState<SourceStatefulWidget> createState();

  @override
  StatefulElement createElement() => _SourceStatefulElement(this);
}

/// The [State] for a [SourceStatefulWidget].
///
/// It has all the life-cycles if a normal [State], with the only difference
/// being that it has a [scope] property.
///
/// It must be used in conjunction with a [SourceStatefulWidget] :
///
/// ```dart
/// class MySource extends SourceStatefulWidget {
///  const MySource({Key? key}): super(key: key);
///
///   @override
///   SourceState<MySource> createState() => _MySourceState();
/// }
///
/// class _MySourceState extends SourceState<MySource> {
///   @override
///   void initState() {
///     // All State life-cycles can be used
///     super.initState();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     // "scope" is a property of SourceState and can be used to read providers
///     scope.watch(someSource);
///   }
/// }
/// ```
abstract class SourceState<T extends SourceStatefulWidget> extends State<T> {
  late final SourceScope scope = SourceScope(context as SourceStatefulElementMixin);
}

/// The [Element] for a [SourceState]
class _SourceStatefulElement extends StatefulElement with SourceStatefulElementMixin {
  _SourceStatefulElement(SourceStatefulWidget super.widget);
}

/// The [Element] mixin for a [StatefulElement]
mixin SourceStatefulElementMixin on StatefulElement {
  final _listenerRemovers = <VoidCallback>[];
  var _dependencies = <Source<Object?>, SourceSubscription<Object?>>{};
  var _oldDependencies = <Source<Object?>, SourceSubscription<Object?>>{};
  final _onDisposeListeners = <VoidCallback>[];

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

  T _watch<T>(Source<T> source) {
    final subscription = _dependencies.putIfAbsent(source, () {
      return source.listen(_listenerForRebuild);
    });
    return subscription.read() as T;
  }

  void _listen<T>(Source<T> source, SourceListener<T> listener) =>
      _listenerRemovers.add(source.listen(listener).cancel);

  SourceSubscription<T> _listenManual<T>(
    Source<T> source,
    void Function(T? previous, T state) listener, {
    required bool fireImmediately,
  }) {
    final subscription = source.listen(listener);
    _onDisposeListeners.add(subscription.cancel);
    if (fireImmediately) Zone.current.runBinaryGuarded(listener, null, subscription.read());
    return SourceSubscriptionProxy(subscription, () {
      _onDisposeListeners.remove(subscription.cancel);
    });
  }

  void _subscribe<T>(Stream<T> stream, void Function(T event) listener) {
    _listenerRemovers.add(stream.listen(listener).cancel);
  }

  VoidCallback _subscribeManual<T>(Stream<T> stream, void Function(T event) listener) {
    final disposer = stream.listen(listener).cancel;
    _onDisposeListeners.add(disposer);
    return disposer;
  }

  VoidCallback _onDispose(VoidCallback onDispose) {
    _onDisposeListeners.add(onDispose);
    return () => _onDisposeListeners.remove(onDispose);
  }

  void _listenerForRebuild(_, _) => markNeedsBuild();

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
