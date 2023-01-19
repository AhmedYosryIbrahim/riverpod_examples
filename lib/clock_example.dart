import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final dateFormatterProvider = Provider<DateFormat>((ref) {
  return DateFormat.MMMd();
});

final clockStateNotifierProvider =
    StateNotifierProvider<Clock, DateTime>((ref) {
  return Clock();
});

class ClockExample extends ConsumerWidget {
  const ClockExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTime = ref.watch(clockStateNotifierProvider);
    final formattedTime = DateFormat.Hms().format(currentTime);
    return Scaffold(
      body: Center(
        child: Text(formattedTime),
      ),
    );
  }
}

class Clock extends StateNotifier<DateTime> {
  Clock() : super(DateTime.now()) {
    _timer = Timer.periodic(const Duration(seconds: 1), (time) {
      state = DateTime.now();
    });
  }

  late Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
