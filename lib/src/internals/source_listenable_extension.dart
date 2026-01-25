import 'package:rivertion/src/source.dart';

extension ListenableSourceExtension<T> on Source<T> {
  SourceListenable<T> get listenable {
    return switch (this) {
      // ignore: deprecated_member_use_from_same_package
      final SourceContainer<T> container => container.source,
      final SourceListenable<T> source => source,
    };
  }
}
