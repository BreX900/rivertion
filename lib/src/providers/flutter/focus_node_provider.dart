import 'package:flutter/material.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';

extension FocusNodeProviderExtensions on ProviderListenable<FocusNode> {
  ProviderListenable<bool> get hasFocus => select(_hasFocus);
  ProviderListenable<bool> get hasPrimaryFocus => select(_hasPrimaryFocus);

  static bool _hasFocus(FocusNode focusNode) => focusNode.hasFocus;
  static bool _hasPrimaryFocus(FocusNode focusNode) => focusNode.hasPrimaryFocus;
}
