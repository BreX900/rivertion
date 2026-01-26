import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivertion/src/sources/listenable_source.dart';

class _Notifier extends ChangeNotifier {
  late int _value = 0;

  int get value => _value;

  set value(int value) {
    _value = value;
    notifyListeners();
  }
}

void main() {
  group('SourceValueListenableExtension', () {
    test('should emit the new value when the ValueListenable changes', () {
      final notifier = _Notifier();
      final source = notifier.sourceBy((notifier) => notifier.value);

      final states = <int>[];
      final subscription = source.listen((_, state) => states.add(state));

      notifier.value = 1;
      notifier.value = 2;

      expect(states, [1, 2]);
      subscription.cancel();
      subscription.cancel(); // Ensure can cancel subscription many times
    });

    test('should not emit a value if the value is the same', () {
      final notifier = _Notifier();
      final source = notifier.sourceBy((notifier) => notifier.value);

      final states = <int>[];
      final subscription = source.listen((_, state) => states.add(state));

      notifier.value = 0;
      notifier.value = 0;

      expect(states, isEmpty);
      subscription.cancel();
      subscription.cancel(); // Ensure can cancel subscription many times
    });

    test('subscription.read() should return the current value', () {
      final notifier = _Notifier();
      final source = notifier.sourceBy((notifier) => notifier.value);
      final subscription = source.listen((_, _) {});

      expect(subscription.read(), 0);

      notifier.value = 5;

      expect(subscription.read(), 5);
      subscription.cancel();
      subscription.cancel(); // Ensure can cancel subscription many times
    });

    test('should stop listening when the subscription is cancelled', () {
      final notifier = _Notifier();
      final source = notifier.sourceBy((notifier) => notifier.value);

      final states = <int>[];
      final subscription = source.listen((_, state) => states.add(state));

      notifier.value = 1;
      subscription.cancel();
      subscription.cancel(); // Ensure can cancel subscription many times
      notifier.value = 2;

      expect(states, [1]);
    });
  });

  group('SourceListenableExtension.sourceBy', () {
    test('should emit when the selected value from a ChangeNotifier changes', () {
      final notifier = _Notifier();
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
      subscription.cancel(); // Ensure can cancel subscription many times
    });
  });

  group('_ListenableSource equality', () {
    test('should be equal if listenable and listener are identical', () {
      final notifier = ChangeNotifier();

      void listener(_) {}

      final source1 = notifier.sourceBy(listener);
      final source2 = notifier.sourceBy(listener);

      expect(source1, equals(source2));
      expect(source1.hashCode, equals(source2.hashCode));
    });

    test('should not be equal if listenables are different', () {
      final notifier1 = ChangeNotifier();
      final notifier2 = ChangeNotifier();

      void listener(_) {}

      final source1 = notifier1.sourceBy(listener);
      final source2 = notifier2.sourceBy(listener);

      expect(source1, isNot(equals(source2)));
    });

    test('should not be equal if listeners are different', () {
      final notifier = ChangeNotifier();

      void listener1(_) {}
      void listener2(_) {}

      final source1 = notifier.sourceBy(listener1);
      final source2 = notifier.sourceBy(listener2);

      expect(source1, isNot(equals(source2)));
    });
  });
}
