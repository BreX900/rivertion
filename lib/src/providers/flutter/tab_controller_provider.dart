import 'package:flutter/material.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';

extension TabControllerProviderExtensions on ProviderListenable<TabController> {
  ProviderListenable<int> get index => select(_index);
  ProviderListenable<int> get previousIndex => select(_previousIndex);
  ProviderListenable<bool> get indexIsChanging => select(_indexIsChanging);
  ProviderListenable<double> get offset => select(_offset);

  static int _index(TabController controller) => controller.index;
  static int _previousIndex(TabController controller) => controller.previousIndex;
  static bool _indexIsChanging(TabController controller) => controller.indexIsChanging;
  static double _offset(TabController controller) => controller.offset;
}
