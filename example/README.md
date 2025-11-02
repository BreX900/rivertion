# Rivertion Example

This directory contains a sample Flutter application demonstrating the usage of the `rivertion` package.

## Features Demonstrated

*   **`SourceBuilder`**: Shows how to use `SourceBuilder` to reactively build widgets based on state changes.
*   **Bloc Interoperability**: Demonstrates how to consume a `Cubit` from the `flutter_bloc` package as a `Source` using the generated `.source` extension.
*   **Riverpod Interoperability**: Shows how to use `SourceConsumerWidget` to seamlessly combine Rivertion and Riverpod, allowing you to watch both Rivertion sources and Riverpod providers in the same widget.

## How to Run

1.  Navigate to the `example` directory:
    ```sh
    cd example
    ```
2.  Install dependencies:
    ```sh
    flutter pub get
    ```
3.  Run the app:
    ```sh
    flutter run
    ```
