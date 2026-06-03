## 5.0.0
- feat: all sources now is exposed via provider

## 4.2.2
- fix: cancel controller subscription
- fix: not emit status update on reactive_forms template
- feat: added `SourceScope` widget to watch a source without `SourceWidget` using `context.watch(soruce)` on experimental folder

## 4.2.1
- fix: fixed incorrect mapping template name

## 4.2.0
- feat: added source extension for `TabController`, `ExpansibleController` and `FocusNode`
- feat: expose source extensions for `TextEditingValue`, `Object?`, `Iterable<T>`
- chore: improved performance for `reactive_forms` sources

## 4.1.1

- chore: added a more informative `toString()` override for `SourceNotifier` and `SourceController` to aid in debugging.
- chore: promoted `select`, `selectWith`, and `where` to be extensions directly on `SourceListenable` for a more consistent and discoverable API. Deprecated older, less direct extension methods on `StateStreamable`, `StateNotifier`, and `ValueListenable`.
- chore: in `reactive_forms` extensions, `select` was renamed to `sourceBy` to better reflect its purpose and align with the library's naming conventions.

## 4.1.0

**Added**
- Added `onError` and `onDone` callbacks to `ref.listenStream` and `ref.listenStreamManual` for more comprehensive stream handling.

## 4.0.0

**BREAKING**: This version introduces a major refactoring of the widget API to align more closely with Riverpod's patterns and improve usability.

- **`SourceScope` is now `SourceRef`**: The `SourceScope` object, previously passed to `SourceBuilder` and available in `SourceState`, has been replaced with `SourceRef`. This change makes the API more consistent with the broader ecosystem.
- **New Implemented `SourceListenable` and `SourceContainer`**: To use directly `SourceController` and `SourceNotifier` on source widgets
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
