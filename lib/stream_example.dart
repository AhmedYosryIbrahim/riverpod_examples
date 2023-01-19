// function return stream of data
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Stream<int> getCounter() {
  return Stream.periodic(const Duration(seconds: 1), (i) {
    return i;
  });
}

final streamCounterProvider = StreamProvider((ref) {
  return getCounter();
});

List<String> names = [
  'John',
  'Paul',
  'George',
  'Ringo',
  'John',
  'Paul',
  'George',
  'Ringo',
  'John',
  'Paul',
  'George',
  'Ringo',
];

final namesProvider = StreamProvider((ref) => ref
    .watch(streamCounterProvider.stream)
    .map((count) => names.getRange(0, count)));

class StreamExample extends ConsumerWidget {
  const StreamExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final namesAsync = ref.watch(namesProvider);
    return Scaffold(
      body: Center(
        child: namesAsync.when(
          data: (data) => ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(data.elementAt(index)),
              );
            },
            itemCount: data.length,
          ),
          error: (error, stackTrace) => const Text('reach the end'),
          loading: () => const CircularProgressIndicator(),
          skipLoadingOnRefresh: false,
          skipLoadingOnReload: false,
        ),
      ),
    );
  }
}
