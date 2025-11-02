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
