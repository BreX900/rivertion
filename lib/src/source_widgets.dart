import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rivertion/src/internals.dart';

abstract interface class SourceRef {
  /// The [BuildContext] of the widget associated to this [WidgetRef].
  ///
  /// This is strictly identical to the [BuildContext] passed to [ConsumerWidget.build].
  BuildContext get context;

  /// Returns the value exposed by a source and rebuild the widget when that
  /// value changes.
  ///
  /// This method should only be used at the "root" of the `build` method of a widget.
  ///
  /// **Good**: Use [watchSource] inside the `build` method.
  /// ```dart
  /// class Example extends SourceWidget {
  ///   @override
  ///   Widget build(BuildContext context, SourceScope scope) {
  ///     // Correct, we are inside the build method and at its root.
  ///     final count = scope.watch(counterSource);
  ///   }
  /// }
  /// ```
  /// **Good**: It is accepted to use [watchSource] at the root of "builders" too.
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
  /// **Bad**: Don't use [watchSource] outside of the `build` method.
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
  /// **Bad**: Don't use [watchSource] inside event handles withing `build` method.
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
  /// - [listenSource], to react to changes on a source, such as for showing modals.
  T watchSource<T>(SourceProvider<T> provider);

  /// Listen to a source and call `listener` whenever its value changes,
  /// without having to take care of removing the listener.
  ///
  /// The [listenSource] method should exclusively be used at the root of the `build`:
  ///
  /// **Good**: Use [listenSource] inside the `build` method.
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
  /// **Bad**: Do not use [listenSource] inside builders.
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
  /// **Bad**: Don't use [listenSource] outside of the `build` method.
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
  /// **Bad**: Don't use [listenSource] inside event handles withing `build` method.
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
  /// - [listenSourceManual], for listening to a provider from outside `build`.
  /// - [watchSource], to listen to providers in a declarative manner.
  /// - [read], to read a provider without listening to it.
  ///
  /// This is useful for showing modals or other imperative logic.
  void listenSource<T>(SourceProvider<T> provider, SourceListener<T> listener);

  /// Listen to a source and call `listener` whenever its value changes.
  ///
  /// As opposed to [listenSource], [listenSourceManual] is not safe to use within the `build`
  /// method of a widget.
  /// Instead, [listenSourceManual] is designed to be used inside [State.initState] or
  /// other [State] life-cycles.
  ///
  /// [listenSourceManual] returns a [SourceSubscription] which can be used to stop
  /// listening to the source, or to read the current value exposed by
  /// the source.
  ///
  /// It is not necessary to call [SourceSubscription.cancel] inside [State.dispose].
  /// When the widget that calls [listenSourceManual] is disposed, the subscription
  /// will be disposed automatically.
  SourceSubscription<T> listenSourceManual<T>(
    SourceProvider<T> provider,
    void Function(T? previous, T state) listener, {
    bool fireImmediately = false,
  });

  void listenStream<T>(Stream<T> stream, void Function(T event) listener);

  VoidCallback listenStreamManual<T>(Stream<T> stream, void Function(T event) listener);

  VoidCallback onDispose(VoidCallback onDispose);
}

class SourceBuilder extends SourceWidget {
  final Widget Function(BuildContext context, SourceRef ref, Widget? child) builder;
  final Widget? child;

  const SourceBuilder({super.key, required this.builder, this.child});

  @override
  Widget build(BuildContext context, SourceRef ref) => builder(context, ref, child);
}

abstract class SourceWidget extends SourceStatefulWidget {
  const SourceWidget({super.key});

  Widget build(BuildContext context, SourceRef ref);

  @override
  SourceState<SourceStatefulWidget> createState() => _SourceState();
}

class _SourceState extends SourceState<SourceWidget> {
  @override
  Widget build(BuildContext context) => widget.build(context, ref);
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
/// being that it has a [ref] property.
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
  late final SourceRef ref = context as SourceRef;
}

/// The [Element] for a [SourceState]
class _SourceStatefulElement extends StatefulElement with SourceStatefulElementMixin {
  _SourceStatefulElement(SourceStatefulWidget super.widget);
}
