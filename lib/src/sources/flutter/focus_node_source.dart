import 'package:flutter/material.dart';
import 'package:rivertion/src/source.dart';
import 'package:rivertion/src/sources/listenable_source.dart';

extension FocusNodeExtension on FocusNode {
  @Deprecated('In favour of FocusNode.provider extension')
  FocusNodeSource get source => FocusNodeSource._(this);
}

final class FocusNodeSource {
  final FocusNode _node;

  FocusNodeSource._(this._node);

  @Deprecated('In favour of FocusNode.provider.hasFocus extension')
  SourceListenable<bool> get hasFocus => _node.sourceBy(_hasFocus);
  @Deprecated('In favour of FocusNode.provider.hasPrimaryFocus extension')
  SourceListenable<bool> get hasPrimaryFocus => _node.sourceBy(_hasPrimaryFocus);

  static bool _hasFocus(FocusNode node) => node.hasFocus;
  static bool _hasPrimaryFocus(FocusNode node) => node.hasPrimaryFocus;
}
