import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final helloWorldProvider = Provider<String>((ref) {
  return 'Hello World';
});

// first way to obtain provider and the most of use

// this is the second way to obtain the provider
class HelloWorldWidget extends StatelessWidget {
  const HelloWorldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer(
          builder: (context, ref, child) {
            final helloWorld = ref.watch(helloWorldProvider);
            return Text(helloWorld);
          },
        ),
      ),
    );
  }
}
