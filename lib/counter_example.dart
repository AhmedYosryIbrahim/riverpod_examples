import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final counterStateProvider = StateProvider<int>((ref) {
  return 0;
});

class CounterExample extends ConsumerWidget {
  const CounterExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterStateProvider);
    ref.listen(counterStateProvider, (perviousState, currentState) {
      print(perviousState);
      print(currentState);
    });
    return Scaffold(
      body: Center(
        child: Text(counter.toString()),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        ref.read(counterStateProvider.notifier).state++;
      }),
    );
  }
}
