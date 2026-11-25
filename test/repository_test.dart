import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtus_app/data/database.dart' as db;
import 'package:virtus_app/models/exercise.dart';
import 'package:virtus_app/models/workout.dart';
import 'package:virtus_app/models/workout_set.dart';
import 'package:virtus_app/repositories/drift_workout_repository.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';

void main() {
  late db.AppDatabase database;
  late DriftWorkoutRepository repository;
  late DriftStatisticsRepository stats;

  Workout sampleWorkout() => Workout(
    name: 'Push day',
    date: DateTime(2026, 11, 20),
    exercises: [
      Exercise(
        name: 'Bench Press',
        sets: [
          WorkoutSet(weight: 60, reps: 8, rir: 2),
          WorkoutSet(weight: 60, reps: 7, rir: 3),
        ],
      ),
    ],
  );

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    repository = DriftWorkoutRepository(database);
    stats = DriftStatisticsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('saveCurrent and loadCurrent round-trip', () async {
    await repository.saveCurrent(sampleWorkout());

    final loaded = await repository.loadCurrent();

    expect(loaded, isNotNull);
    expect(loaded!.name, 'Push day');
    expect(loaded.exercises.single.name, 'Bench Press');
    expect(loaded.exercises.single.sets.length, 2);
  });

  test('finishing moves workout into history', () async {
    final workout = sampleWorkout();
    await repository.saveCurrent(workout);
    await repository.saveWorkout(workout);
    await repository.saveCurrent(
      Workout(
        name: "Today's workout",
        date: DateTime.now(),
        exercises: const [],
      ),
    );

    final history = await repository.loadHistory();

    expect(history, hasLength(1));
    expect(history.single.name, 'Push day');
    expect((await repository.loadCurrent())!.exercises, isEmpty);
  });

  test('delete excludes workout from history', () async {
    final workout = sampleWorkout();
    await repository.saveWorkout(workout);
    await repository.deleteWorkout(workout.id);

    expect(await repository.loadHistory(), isEmpty);
  });

  test('saving creates a reusable exercise template and stats', () async {
    await repository.saveWorkout(sampleWorkout());

    final saved = await stats.savedExercises();
    expect(saved, hasLength(1));
    expect(saved.single.name, 'Bench Press');

    final history = await stats.exerciseHistory(saved.single.id);
    expect(history, hasLength(2));
    expect(history.first.volume, 60 * 8);

    final weekly = await stats.weeklyVolume();
    expect(weekly, hasLength(1));
    expect(weekly.single.volume, 60 * 8 + 60 * 7);
  });

  test('exercise templates keep their dominant muscle group', () async {
    await stats.ensureTemplate(
      name: 'Barbell Bench Press',
      muscleGroup: 'Chest',
    );
    await stats.ensureTemplate(
      name: 'Barbell Bench Press',
      muscleGroup: 'Chest',
    );

    final saved = await stats.savedExercises();

    expect(saved, hasLength(1));
    expect(saved.single.name, 'Barbell Bench Press');
    expect(saved.single.muscleGroup, 'Chest');
  });

  test('weekly goal queries use this week completed workouts', () async {
    final workout = Workout(
      name: 'Push day',
      date: DateTime.now(),
      exercises: [
        Exercise(
          name: 'Bench Press',
          sets: [WorkoutSet(weight: 60, reps: 8, rir: 2)],
        ),
      ],
    );
    await repository.saveWorkout(workout);

    expect(await stats.workoutsThisWeek(), 1);
    expect(await stats.volumeThisWeek(), 60 * 8);
  });

  test(
    'deleting a custom template hides it but keeps logged history',
    () async {
      await stats.ensureTemplate(name: 'My Lift', muscleGroup: 'Custom');
      final created = (await stats.savedExercises()).single;

      await repository.saveWorkout(
        Workout(
          name: 'Push day',
          date: DateTime.now(),
          exercises: [
            Exercise(
              name: 'My Lift',
              sets: [WorkoutSet(weight: 40, reps: 10, rir: 2)],
            ),
          ],
        ),
      );

      await stats.deleteTemplate(created.id);

      expect(await stats.savedExercises(), isEmpty);
      expect(await stats.exerciseHistory(created.id), hasLength(1));
    },
  );
}
