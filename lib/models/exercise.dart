import 'package:uuid/uuid.dart';

import 'workout_set.dart';

class Exercise {
  final String id;
  String name;
  List<WorkoutSet> sets;

  Exercise({
    String? id,
    required this.name,
    required this.sets,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'] as String?,
    name: json['name'] as String,
     sets: (json['sets'] as List<dynamic>)
      .map((s) => WorkoutSet.fromJson(s as Map<String, dynamic>))
      .toList(),
  );
}