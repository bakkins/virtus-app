import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtus_app/data/database.dart' as db;
import 'package:virtus_app/models/routine.dart';
import 'package:virtus_app/repositories/drift_workout_repository.dart';
import 'package:virtus_app/state/workout_controller.dart';

void main() {
  test(
    'finishing a routine workout saves latest sets and clears source',
    () async {
      final database = db.AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftWorkoutRepository(database);
      final controller = WorkoutController(repository: repository);

      controller.startRoutine(
        Routine(
          name: 'Push day',
          exercises: [RoutineExercise(name: 'Bench Press', setCount: 1)],
        ),
      );
      controller.updateSet(0, 0, weight: 50, reps: 5, rir: 1);

      final saved = await controller.finishWorkout();

      expect(saved, isTrue);
      expect(controller.startedFromRoutine, isFalse);

      final history = await repository.loadHistory();
      expect(history, hasLength(1));
      final set = history.single.exercises.single.sets.single;
      expect(set.weight, 50);
      expect(set.reps, 5);
      expect(set.rir, 1);
    },
  );
}
