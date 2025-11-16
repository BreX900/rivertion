# Rivertion

Rivertion is a Flutter state management library that bridges the gap between traditional state holders (like `ValueNotifier`, `ChangeNotifier`, and `Bloc`) and a modern, reactive consumption model inspired by Riverpod.

Instantly convert any `Listenable` or `BlocBase` into a `Source` and consume it in your widgets without the boilerplate of multiple `Builder` widgets or manual listener management.

## Key Feature: A Unified Consumption Model

Tired of juggling `BlocBuilder`, `ValueListenableBuilder`, and manual `addListener` boilerplate? Rivertion simplifies this by converting your existing state holders into a unified `Source` type, which can be consumed consistently in your UI.

### From `ValueNotifier` to `Source`

**Before: The old way**
```dart
ValueListenableBuilder(
  valueListenable: counterNotifier,
  builder: (context, count, _) {
    return Text('Count: $count');
  }
)
```

**After: The Rivertion way**
```dart
SourceBuilder(
  builder: (context, ref, _) {
    // Rebuilds automatically when the notifier changes
    final count = ref.watchSource(counterNotifier.source);
    return Text('Count: $count');
  },
)
```

### From `Bloc` / `Cubit` to `Source`

**Before: The old way**
```dart
BlocBuilder<CounterCubit, int>(
  bloc: counterCubit,
  builder: (context, count) {
    return Text('Count: $count');
  }
)
```

**After: The Rivertion way**
```dart
SourceBuilder(
  builder: (context, ref, _) {
    // The .source extension comes from the generated file
    final count = ref.watchSource(counterCubit.source);
    return Text('Count: $count');
  },
)
```
You get a single, consistent way (`ref.watchSource`) to listen to any state source.

## Core Concepts

### SourceWidget & SourceRef

`SourceWidget` (and its simpler version `SourceBuilder`) is a `StatefulWidget` that provides a `SourceRef` in its `build` method. The ref is the key to interacting with your sources.

-   `ref.watchSource(source)`: Subscribes a widget to a `Source`. The widget will rebuild whenever the source's value changes. This is the most common method you'll use.
-   `ref.listenSource(source, (previous, next) { ... })`: Subscribes to a `Source` to perform actions in response to state changes, like showing a `SnackBar` or navigating. It does *not* cause the widget to rebuild.

### Standalone State: SourceController

For state that doesn't need to be shared with other state management systems, or for simple, local widget state, Rivertion provides `SourceController`. It works just like a `ValueNotifier` but is integrated directly into the Rivertion ecosystem.

```dart
final counterProvider = SourceController(0);

// Watch it in the UI
final count = ref.watchSource(counterProvider.source);

// Update it
counterProvider.state++;
```

## Code Generation for Interoperability

Rivertion also includes a command-line tool to generate support files for other popular packages, enhancing interoperability.

Run the tool with the following command:

```bash
dart run rivertion --packages <package_name> --output <output_path>
```

-   `--packages`: A comma-separated list of packages. Currently supports `bloc`, `riverpod` and `reactive_forms`.
-   `--output`: The path to the output folder for the generated files.

### Example

```bash
dart run rivertion --packages bloc,riverpod,reactive_forms --output lib/generated
```

This will create:
-   `lib/generated/bloc_sources.dart`
-   `lib/generated/source_consumer_widgets.dart`
-   `lib/generated/reactive_form_sources.dart`

### Bloc and Cubit Support

The `bloc_sources.dart` file provides a `.source` extension on `BlocBase`, instantly converting any Bloc or Cubit into a `Source` that can be consumed by `SourceBuilder`.

### Riverpod Interoperability

The `source_consumer_widgets.dart` file provides `SourceConsumerWidget` and `SourceConsumer` to seamlessly use Riverpod providers within a `SourceWidget`, allowing you to mix and match both systems. The `builder` of these widgets will provide a `SourceWidgetRef` that implements both `SourceRef` and `WidgetRef` from Riverpod.

### Reactive Forms Support

The `reactive_form_sources.dart` file provides extensions to easily bind `Source`s to `reactive_forms` controls, keeping your form state perfectly in sync with your application's state.
