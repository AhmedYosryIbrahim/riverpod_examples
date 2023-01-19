import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

@immutable
class Person extends Equatable {
  final String name;
  final int age;
  final String id;

  Person({
    required this.name,
    required this.age,
    String? id,
  }) : id = id ?? const Uuid().v4();

  @override
  List<Object?> get props => [id];

  Person update([String? name, int? age]) {
    return Person(
      name: name ?? this.name,
      age: age ?? this.age,
      id: id,
    );
  }

  String get displayName => '$name ($age years old )';

  @override
  String toString() {
    return 'Person(name: $name, age: $age, id: $id)';
  }
}

class DataModel extends ChangeNotifier {
  final List<Person> _people = [];

  UnmodifiableListView<Person> get people => UnmodifiableListView(_people);

  int get peopleCount => _people.length;

  void addPerson(Person person) {
    _people.add(person);
    notifyListeners();
  }

  void removePerson(Person person) {
    _people.remove(person);
    notifyListeners();
  }

  void updatePerson(Person updatedPerson) {
    final index = _people.indexOf(updatedPerson);
    final oldPerson = _people[index];
    if (oldPerson.name != updatedPerson.name ||
        oldPerson.age != updatedPerson.age) {
      _people[index] = oldPerson.update(updatedPerson.name, updatedPerson.age);
      notifyListeners();
    }
  }
}

final peopleProvider = ChangeNotifierProvider<DataModel>((ref) {
  return DataModel();
});

class PeopleExample extends ConsumerWidget {
  const PeopleExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('People Example')),
      body: Consumer(
        builder: (context, ref, child) {
          final dataModel = ref.watch(peopleProvider);
          return ListView.builder(
            itemBuilder: (context, index) {
              final person = dataModel.people.elementAt(index);
              return ListTile(
                title: GestureDetector(
                    onTap: () async {
                      final updatedPerson =
                          await createOrUpdatePerson(context, person);
                      if (updatedPerson != null) {
                        dataModel.updatePerson(updatedPerson);
                      }
                    },
                    child: Text(
                      person.displayName,
                    )),
              );
            },
            itemCount: dataModel.peopleCount,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final newPerson = await createOrUpdatePerson(context);
          if (newPerson != null) {
            ref.read(peopleProvider.notifier).addPerson(newPerson);
          }
        },
      ),
    );
  }
}

final TextEditingController nameController = TextEditingController();
final TextEditingController ageController = TextEditingController();

Future<Person?> createOrUpdatePerson(BuildContext context,
    [Person? existPerson]) async {
  String? name = existPerson?.name;
  int? age = existPerson?.age;

  nameController.text = name ?? '';
  ageController.text = age?.toString() ?? '';

  return showDialog<Person?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(existPerson == null ? 'Add Person' : 'Update Person'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (value) => name = value,
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              onChanged: (value) => age = int.tryParse(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (name != null && age != null) {
                if (existPerson != null) {
                  Navigator.of(context).pop(existPerson.update(name, age));
                } else {
                  Navigator.of(context).pop(Person(name: name!, age: age!));
                }
              } else {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
