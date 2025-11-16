import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivertion/rivertion.dart';
import 'package:rivertion/src/sources/listenable_source.dart';

// A simple class to test the select method
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
  group('SourceValueListenableExtension', () {
    test('should emit the new value when the ValueListenable changes', () {
      final notifier = ValueNotifier(0);
      final source = notifier.source;

      final states = <int>[];
      final subscription = source.listen((_, state) => states.add(state));

      notifier.value = 1;
      notifier.value = 2;

      expect(states, [1, 2]);
      subscription.cancel();
    });

    test('should not emit a value if the value is the same', () {
      final notifier = ValueNotifier(0);
      final source = notifier.source;

      final states = <int>[];
      final subscription = source.listen((_, state) => states.add(state));

      notifier.value = 0;
      notifier.value = 0;

      expect(states, isEmpty);
      subscription.cancel();
    });

    test('subscription.read() should return the current value', () {
      final notifier = ValueNotifier(0);
      final source = notifier.source;
      final subscription = source.listen((_, _) {});

      expect(subscription.read(), 0);

      notifier.value = 5;

      expect(subscription.read(), 5);
      subscription.cancel();
    });

    test('should stop listening when the subscription is cancelled', () {
      final notifier = ValueNotifier(0);
      final source = notifier.source;

      final states = <int>[];
      final subscription = source.listen((_, state) => states.add(state));

      notifier.value = 1;
      subscription.cancel();
      notifier.value = 2;

      expect(states, [1]);
    });
  });

  group('SourceValueListenableExtension.select', () {
    test('should only emit when the selected value changes', () {
      final notifier = ValueNotifier(MyState(0, 'initial'));
      final source = notifier.select((state) => state.count);

      final states = <int>[];
      final subscription = source.listen((_, state) => states.add(state));

      // Change the name, should not emit
      notifier.value = MyState(0, 'changed');
      expect(states, isEmpty);

      // Change the count, should emit
      notifier.value = MyState(1, 'changed');
      expect(states, [1]);

      // Change the count again
      notifier.value = MyState(2, 'changed');
      expect(states, [1, 2]);

      subscription.cancel();
    });
  });

  group('SourceListenableExtension.sourceBy', () {
    test('should emit when the selected value from a ChangeNotifier changes', () {
      final notifier = ChangeNotifier();
      var count = 0;
      final source = notifier.sourceBy((_) => count);

      final states = <int>[];
      final subscription = source.listen((_, state) => states.add(state));

      // Notify without changing the value, should not emit
      notifier.notifyListeners();
      expect(states, isEmpty);

      // Change the value and notify, should emit
      count = 1;
      notifier.notifyListeners();
      expect(states, [1]);

      // Notify again without change, should not emit
      notifier.notifyListeners();
      expect(states, [1]);

      subscription.cancel();
    });
  });

  group('_ListenableSource equality', () {
    test('should be equal if listenable are identical', () {
      final notifier = ValueNotifier(0);

      final source1 = notifier.source;
      final source2 = notifier.source;

      expect(source1, equals(source2));
      expect(source1.hashCode, equals(source2.hashCode));
    });

    test('should not be equal if listenables are different', () {
      final notifier1 = ValueNotifier(0);
      final notifier2 = ValueNotifier(0);

      final source1 = notifier1.source;
      final source2 = notifier2.source;

      expect(source1, isNot(equals(source2)));
    });
  });
}
