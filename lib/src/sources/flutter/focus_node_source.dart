import 'package:flutter/material.dart';
import 'package:rivertion/rivertion.dart';

extension FocusNodeExtension on FocusNode {
  FocusNodeSource get source => FocusNodeSource._(this);
}

final class FocusNodeSource {
  final FocusNode _node;

  FocusNodeSource._(this._node);

  SourceListenable<bool> get hasFocus => _node.sourceBy(_hasFocus);
  SourceListenable<bool> get hasPrimaryFocus => _node.sourceBy(_hasPrimaryFocus);

  static bool _hasFocus(FocusNode node) => node.hasFocus;
  static bool _hasPrimaryFocus(FocusNode node) => node.hasPrimaryFocus;
}
