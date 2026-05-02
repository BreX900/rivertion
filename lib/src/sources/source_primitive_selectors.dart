import 'package:rivertion/rivertion.dart';

extension ObjectSourceExtensions on SourceListenable<Object?> {
  @Deprecated('In favour of ProviderListenable<Object?>.isNull extension')
  SourceListenable<bool> get isNull => select(_isNull);

  static bool _isNull(Object? value) => value == null;
}

extension StringSourceExtensions on SourceListenable<String> {
  @Deprecated('In favour of ProviderListenable<String>.isEmpty extension')
  SourceListenable<bool> get isEmpty => select(_isEmpty);
  @Deprecated('In favour of ProviderListenable<String>.isBlank extension')
  SourceListenable<bool> get isBlank => select(_isBlank);

  static bool _isEmpty(String value) => value.isEmpty;
  static bool _isBlank(String value) => value.trim().isEmpty;
}

extension IterableSourceExtensions<T> on SourceListenable<Iterable<T>> {
  @Deprecated('In favour of ProviderListenable<Iterable<T>>.contains extension')
  SourceListenable<bool> contains(T? element) => selectWith(element, _contains);

  static bool _contains<T>(T? element, Iterable<T> elements) => elements.contains(element);
}
