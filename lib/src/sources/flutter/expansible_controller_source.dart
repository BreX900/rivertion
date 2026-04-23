import 'package:flutter/material.dart';
import 'package:rivertion/src/source.dart';
import 'package:rivertion/src/sources/listenable_source.dart';

extension SourceExpansibleControllerExtension on ExpansibleController {
  ExpansibleControllerSource get source => ExpansibleControllerSource._(this);
}

final class ExpansibleControllerSource {
  final ExpansibleController _controller;

  ExpansibleControllerSource._(this._controller);

  SourceListenable<bool> get isExpanded => _controller.sourceBy(_isExpanded);

  static bool _isExpanded(ExpansibleController controller) => controller.isExpanded;
}
