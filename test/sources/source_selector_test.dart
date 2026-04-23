import 'package:flutter_test/flutter_test.dart';
import 'package:rivertion/src/source.dart';
import 'package:rivertion/src/source_controller.dart';
import 'package:rivertion/src/sources/source_selector.dart';

class MyState {
  final int count;
  final String name;

  MyState(this.count, this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyState &&
          runtimeType == other.runtimeType &&
          count == other.count &&
          name == other.name;

  @override
  int get hashCode => count.hashCode ^ name.hashCode;
}

void main() {
  group('SourceSelector', () {
    late SourceController<MyState> source;
    late SourceListenable<int> selectedSource;

    setUp(() {
      source = SourceController(MyState(0, 'initial'));
      selectedSource = source.source.select((state) => state.count);
    });

    test('should only emit when the selected value changes', () {
      final states = <int>[];
      final subscription = selectedSource.listen((_, state) => states.add(state));

      // Change the name, should not emit
      source.state = MyState(0, 'changed');
      expect(states, isEmpty);

      // Change the count, should emit
      source.state = MyState(1, 'changed');
      expect(states, [1]);

      // Change nothing, should not emit
      source.state = MyState(1, 'changed');
      expect(states, [1]);

      subscription.cancel();
      subscription.cancel(); // Ensure can cancel subscription many times
    });

    test('read() should return the current selected value', () {
      final subscription = selectedSource.listen((_, _) {});
      expect(subscription.read(), 0);

      source.state = MyState(5, 'new');
      expect(subscription.read(), 5);

      subscription.cancel();
      subscription.cancel(); // Ensure can cancel subscription many times
    });
  });

  group('SourceArgSelector', () {
    late SourceController<MyState> source;
    late SourceListenable<String> selectedSource;

    setUp(() {
      source = SourceController(MyState(0, 'initial'));
      selectedSource = source.source.selectWith('prefix', (arg, state) => '$arg: ${state.name}');
    });

    test('should only emit when the selected value changes', () {
      final states = <String>[];
      final subscription = selectedSource.listen((_, state) => states.add(state));

      // Change the count, should not emit because the selected name is the same
      source.state = MyState(1, 'initial');
      expect(states, isEmpty);

      // Change the name, should emit
      source.state = MyState(1, 'changed');
      expect(states, ['prefix: changed']);

      subscription.cancel();
      subscription.cancel(); // Ensure can cancel subscription many times
    });

    test('read() should return the current selected value with argument', () {
      final subscription = selectedSource.listen((_, _) {});
      expect(subscription.read(), 'prefix: initial');

      source.state = MyState(0, 'new');
      expect(subscription.read(), 'prefix: new');

      subscription.cancel();
      subscription.cancel(); // Ensure can cancel subscription many times
    });
  });

  group('Equality', () {
    test('SourceSelector should be equal if source and selector are identical', () {
      final source = SourceController(0);
      int selector(int n) => n;

      final selector1 = SelectorSourceListenable(source, selector);
      final selector2 = SelectorSourceListenable(source, selector);

      expect(selector1, equals(selector2));
      expect(selector1.hashCode, equals(selector2.hashCode));
    });

    test('SourceArgSelector should be equal if source, arg, and selector are identical', () {
      final source = SourceController(0);
      String selector(String arg, int n) => '$arg: $n';
      const arg = 'value';

      final selector1 = ArgSelectorSourceListenable(source, arg, selector);
      final selector2 = ArgSelectorSourceListenable(source, arg, selector);

      expect(selector1, equals(selector2));
      expect(selector1.hashCode, equals(selector2.hashCode));
    });
  });
}
