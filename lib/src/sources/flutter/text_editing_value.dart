import 'package:flutter/services.dart';
import 'package:rivertion/src/source.dart';

extension SourceTextEditingValueExtension on SourceListenable<TextEditingValue> {
  @Deprecated('In favour of ProviderListenable<TextEditingValue>.text')
  SourceListenable<String> get text => select(_text);
  @Deprecated('In favour of ProviderListenable<TextEditingValue>.selection')
  SourceListenable<TextSelection> get selection => select(_selection);
  @Deprecated('In favour of ProviderListenable<TextEditingValue>.composing')
  SourceListenable<TextRange> get composing => select(_composing);

  static String _text(TextEditingValue value) => value.text;
  static TextSelection _selection(TextEditingValue value) => value.selection;
  static TextRange _composing(TextEditingValue value) => value.composing;
}
