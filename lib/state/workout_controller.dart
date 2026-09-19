import 'package:flutter/foundation.dart';
import 'package:virtus_app/models/exercise.dart';
import 'package:virtus_app/models/workout.dart';
import 'package:virtus_app/models/workout_set.dart';

class WorkoutController extends ChangeNotifier {
  final Workout _workout;

  WorkoutController()
      : _workout = Workout(
          name: 'Today\'s workout',
          date: DateTime.now(),
          exercises: [],
        );

  Workout get workout => _workout;

  List<Exercise> get exercises => List.unmodifiable(_workout.exercises);

  void addExercise(String name) {
    _workout.exercises.add(
      Exercise(
        name: name,
        sets: [WorkoutSet(weight: 0, reps: 0, rir: 0)],
      ),
    );
    notifyListeners();
  }

  void updateSet(
    int exerciseIndex,
    int setIndex, {
    double? weight,
    int? reps,
    int? rir,
  }) {
    final exercise = _workout.exercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= exercise.sets.length) return;
    final set = exercise.sets[setIndex];
    if (weight != null) set.weight = weight;
    if (reps != null) set.reps = reps;
    if (rir != null) set.rir = rir;
    notifyListeners();
  }

  void addSet(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _workout.exercises.length) return;
    final exercise = _workout.exercises[exerciseIndex];
    final previous = exercise.sets.isEmpty ? null : exercise.sets.last;
    exercise.sets.add(
      WorkoutSet(
        weight: previous?.weight ?? 0,
        reps: 0,
        rir: previous?.rir ?? 0,
      ),
    );
    notifyListeners();
  }
}