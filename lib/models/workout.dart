import 'package:virtus_app/models/exercise.dart';

class Workout {
  String name;
  DateTime date;
  List<Exercise> exercises;

  Workout({
    required this.name,
    required this.date,
    required this.exercises,
  });
}