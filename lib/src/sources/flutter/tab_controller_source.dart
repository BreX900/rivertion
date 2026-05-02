import 'package:flutter/material.dart';
import 'package:rivertion/src/source.dart';
import 'package:rivertion/src/sources/listenable_source.dart';

extension SourceTabControllerExtension on TabController {
  @Deprecated('In favour of TabController.provider extension')
  TabControllerSource get source => TabControllerSource._(this);
}

final class TabControllerSource {
  final TabController _controller;

  TabControllerSource._(this._controller);

  @Deprecated('In favour of TabController.provider.index extension')
  SourceListenable<int> get index => _controller.sourceBy(_index);
  @Deprecated('In favour of TabController.provider.previousIndex extension')
  SourceListenable<int> get previousIndex => _controller.sourceBy(_previousIndex);
  @Deprecated('In favour of TabController.provider.indexIsChanging extension')
  SourceListenable<bool> get indexIsChanging => _controller.sourceBy(_indexIsChanging);
  @Deprecated('In favour of TabController.provider.offset extension')
  SourceListenable<double> get offset => _controller.sourceBy(_offset);

  static int _index(TabController controller) => controller.index;
  static int _previousIndex(TabController controller) => controller.previousIndex;
  static bool _indexIsChanging(TabController controller) => controller.indexIsChanging;
  static double _offset(TabController controller) => controller.offset;
}
