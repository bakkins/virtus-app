import 'package:uuid/uuid.dart';
import 'package:virtus_app/models/exercise.dart';

class Workout {
  static const int schemaVersion = 1;

  final String id;
  String name;
  DateTime date;
  DateTime createdAt;
  DateTime updatedAt;
  List<Exercise> exercises;

  Workout({
    String? id,
    required this.name,
    required this.date,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.exercises,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'id': id,
    'name': name,
    'date': date.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
    id: json['id'] as String?,
    name: json['name'] as String,
    date: DateTime.parse(json['date'] as String),
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    exercises: (json['exercises'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
