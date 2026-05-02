import 'package:flutter/widgets.dart';
import 'package:rivertion/src/source.dart';
import 'package:rivertion/src/sources/listenable_source.dart';

extension SourceScrollControllerExtension on ScrollController {
  @Deprecated('In favour of ScrollController.provider extension')
  ScrollControllerSource get source => ScrollControllerSource._(this);
}

final class ScrollControllerSource<T extends ScrollController> {
  final T _controller;

  ScrollControllerSource._(this._controller);

  @Deprecated('In favour of ScrollController.provider.hasClients extension')
  SourceListenable<bool> get hasClients => _controller.sourceBy(_hasClients);

  static bool _hasClients(ScrollController controller) => controller.hasClients;
}

extension SourcePageControllerExtension on PageController {
  @Deprecated('In favour of PageController.provider extension')
  PageControllerSource get source => PageControllerSource._(this);
}

final class PageControllerSource extends ScrollControllerSource<PageController> {
  PageControllerSource._(super._controller) : super._();

  @Deprecated('In favour of PageController.provider.page extension')
  SourceListenable<double?> get page => _controller.sourceBy(_page);

  static double? _page(PageController controller) => controller.page;
}
