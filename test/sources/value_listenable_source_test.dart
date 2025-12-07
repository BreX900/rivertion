import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivertion/src/sources/value_listenable_source.dart';

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
