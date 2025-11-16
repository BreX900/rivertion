import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivertion/rivertion.dart';

void main() {
  late SourceController<int> notifier;

  const initialValue = 0;
  const nextValue = 1;

  setUp(() {
    notifier = SourceController(initialValue);
  });

  tearDown(() {
    notifier.dispose();
  });

  group('listenSource', () {
    testWidgets('should call the listener without triggering a rebuild', (tester) async {
      var buildCount = 0;
      var listenCount = 0;

      await tester.pumpWidget(
        SourceBuilder(
          builder: (context, ref, _) {
            ref.listenSource(notifier, (_, _) => listenCount += 1);
            buildCount += 1;
            return const SizedBox.shrink();
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(buildCount, 1);
      expect(listenCount, 0);

      // Step 1

      notifier.state += 1;

      await tester.pumpAndSettle();

      expect(buildCount, 1);
      expect(listenCount, 1);
    });
  });

  group('watchSource', () {
    testWidgets('should rebuild the widget when the source emits a new state', (tester) async {
      var buildCount = 0;
      var count = -1;

      await tester.pumpWidget(
        SourceBuilder(
          builder: (context, ref, _) {
            count = ref.watchSource(notifier);
            buildCount += 1;
            return const SizedBox.shrink();
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(buildCount, 1);
      expect(count, initialValue);

      // Ensure widget rebuild with new source state

      notifier.state += nextValue;

      await tester.pumpAndSettle();

      expect(buildCount, 2);
      expect(count, nextValue);
    });

    testWidgets(
      'should not rebuild when the ticker is disabled, but should rebuild with the latest state once enabled',
      (tester) async {
        final tickerModeNotifier = ValueNotifier(false);
        var buildCount = 0;
        var count = -1;

        await tester.pumpWidget(
          ValueListenableBuilder(
            valueListenable: tickerModeNotifier,
            builder: (context, value, child) => TickerMode(enabled: value, child: child!),
            child: SourceBuilder(
              builder: (context, ref, _) {
                count = ref.watchSource(notifier);
                buildCount += 1;
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(buildCount, 1);
        expect(count, initialValue);

        // Ensure widget not rebuild

        notifier.state += nextValue;

        await tester.pumpAndSettle();

        expect(buildCount, 1);
        expect(count, initialValue);

        // Ensure widget rebuild after ticker mode is enabled

        tickerModeNotifier.value = true;

        await tester.pumpAndSettle();

        expect(buildCount, 2);
        expect(count, nextValue);
      },
    );

    testWidgets(
      'should not rebuild when the ticker is re-enabled if the source has not emitted a new state',
      (tester) async {
        final tickerModeNotifier = ValueNotifier(false);
        var buildCount = 0;
        var count = -1;

        await tester.pumpWidget(
          ValueListenableBuilder(
            valueListenable: tickerModeNotifier,
            builder: (context, value, child) => TickerMode(enabled: value, child: child!),
            child: SourceBuilder(
              builder: (context, ref, _) {
                count = ref.watchSource(notifier);
                buildCount += 1;
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(buildCount, 1);
        expect(count, initialValue);

        // Ensure widget not rebuild after ticker mode is enabled

        tickerModeNotifier.value = true;

        await tester.pumpAndSettle();

        expect(buildCount, 1);
        expect(count, initialValue);
      },
    );
  });
}
