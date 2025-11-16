import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../tool/templates/bloc_source.dart';
import '../tool/templates/riverpod_source_consumer.dart';

// A Riverpod provider.
final riverpodCounterProvider = StateProvider((ref) => 0);

// A Cubit for state management.
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}

void main() {
  final counterCubit = CounterCubit();

  runApp(ProviderScope(child: MyApp(counterCubit: counterCubit)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.counterCubit});

  final CounterCubit counterCubit;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Rivertion Example')),
        body: Center(
          child: SourceConsumer(
            builder: (context, ref, _) {
              // Watch the Cubit's state using the .source extension.
              final cubitCount = ref.watchSource(counterCubit.source);

              // Watch the Riverpod provider.
              final riverpodCount = ref.watch(riverpodCounterProvider);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Cubit value:'),
                  Text('$cubitCount', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 20),
                  const Text('Riverpod value:'),
                  Text('$riverpodCount', style: Theme.of(context).textTheme.headlineMedium),
                ],
              );
            },
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                // Increment the Cubit's state.
                counterCubit.increment();
              },
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 10),
            Consumer(
              builder: (context, ref, _) {
                return FloatingActionButton(
                  onPressed: () {
                    // Increment the Riverpod provider's state.
                    ref.read(riverpodCounterProvider.notifier).state++;
                  },
                  child: const Icon(Icons.add),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
