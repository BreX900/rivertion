import 'package:flutter/services.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';

extension TextEditingValueProviderExtensions on ProviderListenable<TextEditingValue> {
  ProviderListenable<String> get text => select(_text);
  ProviderListenable<TextSelection> get selection => select(_selection);
  ProviderListenable<TextRange> get composing => select(_composing);

  static String _text(TextEditingValue value) => value.text;
  static TextSelection _selection(TextEditingValue value) => value.selection;
  static TextRange _composing(TextEditingValue value) => value.composing;
}
