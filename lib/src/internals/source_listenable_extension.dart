import 'package:rivertion/src/source.dart';

extension ListenableSourceExtension<T> on Source<T> {
  SourceListenable<T> get listenable {
    return switch (this) {
      final SourceContainer<T> container => container.source,
      final SourceListenable<T> source => source,
    };
  }
}
