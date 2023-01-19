import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_example/add_person_example.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherExample extends ConsumerWidget {
  const WeatherExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Example'),
      ),
      body: Column(children: [
        weatherAsync.when(
          data: (weather) =>
              Text(weather, style: const TextStyle(fontSize: 40)),
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text(error.toString()),
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              final city = City.values[index];
              final isSelected = ref.watch(currentCityProvider) == city;
              return ListTile(
                title: Text(city.toString().split('.').last),
                trailing: isSelected
                    ? const Icon(Icons.check)
                    : const Icon(Icons.check_box_outline_blank),
                onTap: () {
                  ref.read(currentCityProvider.notifier).state = city;
                },
              );
            },
            itemCount: City.values.length,
          ),
        ),
      ]),
    );
  }
}

enum City {
  alexandria,
  cairo,
  giza,
}

typedef WeatherEmojie = String;

Future<WeatherEmojie> getWeatherEmojie(City city) {
  return Future.delayed(
      const Duration(seconds: 1),
      () => {
            City.alexandria: '🌤',
            City.cairo: '🌥',
            City.giza: '🌦',
          }[city]!);
}

final currentCityProvider = StateProvider<City?>((ref) {
  return null;
});

final weatherProvider = FutureProvider.autoDispose<WeatherEmojie>((ref) {
  final city = ref.watch(currentCityProvider);

  if (city != null) {
    return getWeatherEmojie(city);
  } else {
    return '🤷‍♂️';
  }
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});
