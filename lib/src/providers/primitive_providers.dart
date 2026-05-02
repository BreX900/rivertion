import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';

extension TextEditingValueProviderExtension<T extends Object?> on ProviderListenable<T> {
  ProviderListenable<bool> get isNull => select(_isNull);
  ProviderListenable<bool> get isNotNull => select(_isNotNull);

  static bool _isNull(Object? value) => value == null;
  static bool _isNotNull(Object? value) => value != null;
}

extension StringProviderExtension on ProviderListenable<String> {
  ProviderListenable<bool> get isEmpty => select(_isEmpty);
  ProviderListenable<bool> get isBlank => select(_isBlank);

  static bool _isEmpty(String value) => value.isEmpty;
  static bool _isBlank(String value) => value.trim().isEmpty;
}

extension IterableProviderExtension<T> on ProviderListenable<Iterable<T>> {
  ProviderListenable<bool> get isEmpty => select(_isEmpty);
  ProviderListenable<bool> contains(T? element) =>
      select((elements) => _contains(element, elements));

  static bool _isEmpty(Iterable<Object?> elements) => elements.isEmpty;
  static bool _contains<T>(T? element, Iterable<T> elements) => elements.contains(element);
}
