import 'package:flutter/services.dart';
import 'package:rivertion/src/source.dart';

extension SourceTextEditingValueExtension on SourceListenable<TextEditingValue> {
  SourceListenable<String> get text => select(_text);
  SourceListenable<TextSelection> get selection => select(_selection);
  SourceListenable<TextRange> get composing => select(_composing);

  static String _text(TextEditingValue value) => value.text;
  static TextSelection _selection(TextEditingValue value) => value.selection;
  static TextRange _composing(TextEditingValue value) => value.composing;
}
