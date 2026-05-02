import 'package:flutter/material.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';

extension ExpansibleControllerProviderExtensions on ProviderListenable<ExpansibleController> {
  ProviderListenable<bool> get isExpanded => select(_isExpanded);

  static bool _isExpanded(ExpansibleController controller) => controller.isExpanded;
}
