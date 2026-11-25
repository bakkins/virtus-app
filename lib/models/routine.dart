import 'package:uuid/uuid.dart';

class RoutineExercise {
  RoutineExercise({
    String? id,
    required this.name,
    this.setCount = 1,
    this.templateId,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String name;
  int setCount;
  final String? templateId;
}

class Routine {
  Routine({
    String? id,
    required this.name,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.exercises,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String id;
  String name;
  final DateTime createdAt;
  DateTime updatedAt;
  List<RoutineExercise> exercises;
}
