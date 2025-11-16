## 4.0.0

**BREAKING**: This version introduces a major refactoring of the widget API to align more closely with Riverpod's patterns and improve usability.

- **`SourceScope` is now `SourceRef`**: The `SourceScope` object, previously passed to `SourceBuilder` and available in `SourceState`, has been replaced with `SourceRef`. This change makes the API more consistent with the broader ecosystem.
- **New `watchSource` Method**: The `scope.watch()` method has been renamed to `ref.watchSource()` to clarify that it is specifically for watching Rivertion `Source` objects.
- **Riverpod Interoperability with `SourceWidgetRef`**: The `ConsumerScope` has been replaced by `SourceWidgetRef`, an extension type that implements both `SourceRef` and Riverpod's `WidgetRef`. This allows for direct calls to both `ref.watchSource()` (for Rivertion sources) and `ref.watch()` (for Riverpod providers) from the same `ref` object.
- **API Cleanup**: Renamed `scope.listen` to `ref.listenSource`, `scope.listenManual` to `ref.listenSourceManual`, `scope.subscribe` to `ref.listenStream`, and `scope.subscribeManual` to `ref.listenStreamManual` for consistency.

## 3.1.0

- Added ability to filter states emitted by source using `Source.where` method
- Formatted code
- Fixed incorrect templates 

## 3.0.0

**BREAKING**: Complete rewrite of the library.

- Introduced a new core concept: `Source`, a unified reactive stream for state consumption.
- Replaced previous state management approach with `SourceWidget` and `SourceBuilder` for a consistent, Riverpod-inspired API.

**Added**

- **From `Listenable` to `Source`**: Convert any `Listenable` (e.g., `ValueNotifier`, `ChangeNotifier`) into a reactive `Source` using `.source` and `.sourceBy()` extensions.
- **Code Generation**: Added a command-line tool to generate boilerplate for interoperability with popular packages.
- **Bloc Support**: Added generated code to convert `Bloc` and `Cubit` instances into a `Source` for consumption in `SourceBuilder`.
- **Riverpod Interop**: Added generated `SourceConsumerWidget` to use Riverpod providers inside a `SourceWidget`.
- **Reactive Forms Interop**: Added generated extensions to bind `Source`s to `reactive_forms` controls.
- **Standalone State**: Included `SourceController` for simple, self-contained state management.
