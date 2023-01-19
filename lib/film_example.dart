import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class Film extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isFavorite;

  const Film({
    required this.id,
    required this.title,
    required this.description,
    required this.isFavorite,
  });

  Film copy({required bool isFavorite}) => Film(
        id: id,
        title: title,
        description: description,
        isFavorite: isFavorite,
      );

  @override
  String toString() {
    return 'Film(id: $id, title: $title, description: $description, isFavorite: $isFavorite)';
  }

  @override
  List<Object?> get props => [id, isFavorite];
}

const List<Film> allFilms = [
  Film(
    id: '1',
    title: 'the dark knight',
    description: 'Description for the dark knight',
    isFavorite: false,
  ),
  Film(
    id: '2',
    title: 'the godfather',
    description: 'Description for the godfather',
    isFavorite: false,
  ),
  Film(
    id: '3',
    title: 'the godfather: part II',
    description: 'Description for the godfather: part II',
    isFavorite: false,
  ),
  Film(
    id: '4',
    title: 'the lord of the rings: the return of the king',
    description:
        'Description for the lord of the rings: the return of the king',
    isFavorite: false,
  ),
];

class FilmNotifier extends StateNotifier<List<Film>> {
  FilmNotifier() : super(allFilms);

  void updateFilm(Film film, bool isFavorite) {
    state = state
        .map(
          (thisFilm) => thisFilm.id == film.id
              ? thisFilm.copy(
                  isFavorite: isFavorite,
                )
              : thisFilm,
        )
        .toList();
  }
}

enum FavoriteStatus {
  all,
  favorite,
  notFavorite,
}

final favoriteStatusProvider = StateProvider<FavoriteStatus>(
  (_) => FavoriteStatus.all,
);

// all films provider
final allFilmsProvider = StateNotifierProvider<FilmNotifier, List<Film>>((ref) {
  return FilmNotifier();
});

// favorite film provider
final favoriteFilmsProvider = Provider<Iterable<Film>>((ref) {
  return ref.watch(allFilmsProvider).where((film) => film.isFavorite);
});

// not favorite films provider

final notFavoriteProvider = Provider<Iterable<Film>>((ref) {
  return ref.watch(allFilmsProvider).where((film) => !film.isFavorite);
});

class FilmExample extends ConsumerWidget {
  const FilmExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Films example')),
      body: Column(children: [
        const FilterWidget(),
        Consumer(
          builder: (context, ref, child) {
            final filter = ref.watch(favoriteStatusProvider);
            switch (filter) {
              case FavoriteStatus.all:
                return ListFilmsWidget(provider: allFilmsProvider);
              case FavoriteStatus.favorite:
                return ListFilmsWidget(provider: favoriteFilmsProvider);
              case FavoriteStatus.notFavorite:
                return ListFilmsWidget(provider: notFavoriteProvider);
            }
          },
        )
      ]),
    );
  }
}

class ListFilmsWidget extends ConsumerWidget {
  final AlwaysAliveProviderBase<Iterable<Film>> provider;
  const ListFilmsWidget({super.key, required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(provider);
    return Expanded(
      child: ListView.builder(
        itemCount: films.length,
        itemBuilder: (context, index) {
          final film = films.elementAt(index);
          final isFavoriteIcon =
              film.isFavorite ? Icons.favorite : Icons.favorite_border;
          return ListTile(
            title: Text(film.title),
            subtitle: Text(film.description),
            trailing: IconButton(
              icon: Icon(
                isFavoriteIcon,
                color: Colors.red,
              ),
              onPressed: () {
                ref
                    .read(allFilmsProvider.notifier)
                    .updateFilm(film, !film.isFavorite);
              },
            ),
          );
        },
      ),
    );
  }
}

class FilterWidget extends ConsumerWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteStatus = ref.watch(favoriteStatusProvider);
    return DropdownButton(
      items: FavoriteStatus.values
          .map((fs) => DropdownMenuItem(
                value: fs,
                child: Text(fs.toString().split('.').last),
              ))
          .toList(),
      onChanged: (FavoriteStatus? value) {
        if (value != null) {
          ref.read(favoriteStatusProvider.notifier).state = value;
        }
      },
      value: favoriteStatus,
    );
  }
}
