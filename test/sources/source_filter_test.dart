import 'package:flutter_test/flutter_test.dart';
import 'package:rivertion/rivertion.dart';
import 'package:rivertion/src/sources/source_filter.dart';

void main() {
  group('SourceFilter', () {
    test('should only emit when the condition is met', () {
      final source = SourceController(0);
      // This filter will only allow even numbers to be emitted
      final filteredSource = SourceFilter(source, (previous, next) => next % 2 == 0);

      final states = <int>[];
      final subscription = filteredSource.listen((_, state) => states.add(state));

      source.state = 1; // Should be filtered out
      source.state = 2; // Should be emitted
      source.state = 3; // Should be filtered out
      source.state = 4; // Should be emitted

      expect(states, [2, 4]);
      subscription.cancel();
    });

    test('should not emit if the condition is never met', () {
      final source = SourceController(0);
      // This filter will never allow any value
      final filteredSource = SourceFilter(source, (previous, next) => false);

      final states = <int>[];
      final subscription = filteredSource.listen((_, state) => states.add(state));

      source.state = 1;
      source.state = 2;
      source.state = 3;

      expect(states, isEmpty);
      subscription.cancel();
    });

    test('should stop listening when the subscription is cancelled', () {
      final source = SourceController(0);
      final filteredSource = SourceFilter(source, (previous, next) => true);

      final states = <int>[];
      final subscription = filteredSource.listen((_, state) => states.add(state));

      source.state = 1;
      subscription.cancel();
      source.state = 2;

      expect(states, [1]);
    });
  });

  group('SourceFilter equality', () {
    test('should be equal if source and condition are identical', () {
      final source = SourceController(0);
      bool condition(int p, int n) => n.isEven;

      final filter1 = SourceFilter(source, condition);
      final filter2 = SourceFilter(source, condition);

      expect(filter1, equals(filter2));
      expect(filter1.hashCode, equals(filter2.hashCode));
    });

    test('should not be equal if sources are different', () {
      final source1 = SourceController(0);
      final source2 = SourceController(0);
      bool condition(int p, int n) => n.isEven;

      final filter1 = SourceFilter(source1, condition);
      final filter2 = SourceFilter(source2, condition);

      expect(filter1, isNot(equals(filter2)));
    });

    test('should not be equal if conditions are different', () {
      final source = SourceController(0);
      bool condition1(int p, int n) => n.isEven;
      bool condition2(int p, int n) => n.isOdd;

      final filter1 = SourceFilter(source, condition1);
      final filter2 = SourceFilter(source, condition2);

      expect(filter1, isNot(equals(filter2)));
    });
  });
}
