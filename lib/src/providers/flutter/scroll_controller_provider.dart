import 'package:flutter/widgets.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';

extension ScrollControllerProviderExtensions on ProviderListenable<ScrollController> {
  ProviderListenable<bool> get hasClients => select(_hasClients);

  static bool _hasClients(ScrollController controller) => controller.hasClients;
}

extension PageControllerProviderExtension on ProviderListenable<PageController> {
  ProviderListenable<double?> get page => select(_page);

  static double? _page(PageController controller) => controller.page;
}
