import 'package:virtus_app/models/workout.dart';

abstract class WorkoutRepository {
  Future<Workout?> loadCurrent();
  Future<void> saveCurrent(Workout workout);
  Future<void> saveWorkout(Workout workout);
  Future<List<Workout>> loadHistory();
}