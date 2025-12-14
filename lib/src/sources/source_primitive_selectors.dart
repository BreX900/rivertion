import 'package:rivertion/rivertion.dart';

extension ObjectSourceExtensions<T extends Object> on SourceListenable<T?> {
  SourceListenable<bool> get isNull => select(_isNull);

  static bool _isNull(Object? value) => value == null;
}

extension StringSourceExtensions on SourceListenable<String> {
  SourceListenable<bool> get isEmpty => select(_isEmpty);
  SourceListenable<bool> get isBlank => select(_isBlank);

  static bool _isEmpty(String value) => value.isEmpty;
  static bool _isBlank(String value) => value.trim().isEmpty;
}

extension IterableSourceExtensions<T> on SourceListenable<Iterable<T>> {
  SourceListenable<bool> contains(T? element) => selectWith(element, _contains);

  static bool _contains<T>(T? element, Iterable<T> elements) => elements.contains(element);
}
