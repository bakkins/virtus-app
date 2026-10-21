import 'package:virtus_app/models/workout.dart';

abstract class WorkoutRepository {
  Future<Workout?> loadCurrent();
  Future<void> saveCurrent(Workout workout);
}