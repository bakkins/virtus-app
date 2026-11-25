import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:virtus_app/data/database.dart' as db;
import 'package:virtus_app/models/exercise.dart';
import 'package:virtus_app/models/workout.dart';
import 'package:virtus_app/models/workout_set.dart';
import 'package:virtus_app/repositories/workout_repository.dart';

class DriftWorkoutRepository implements WorkoutRepository {
  DriftWorkoutRepository(this._db);

  final db.AppDatabase _db;

  static const _draft = 'draft';
  static const _completed = 'completed';

  @override
  Future<Workout?> loadCurrent() async {
    final row =
        await (_db.select(_db.workouts)
              ..where((w) => w.status.equals(_draft) & w.deletedAt.isNull()))
            .getSingleOrNull();

    if (row == null) return null;
    return _hydrate(row);
  }

  @override
  Future<void> saveCurrent(Workout workout) async {
    await _db.transaction(() async {
      final drafts = await (_db.select(
        _db.workouts,
      )..where((w) => w.status.equals(_draft))).get();

      for (final draft in drafts) {
        await (_db.delete(
          _db.workouts,
        )..where((w) => w.id.equals(draft.id))).go();
      }

      await _insertTree(workout, status: _draft);
    });
  }

  @override
  Future<void> saveWorkout(Workout workout) async {
    await _db.transaction(() async {
      final updated =
          await (_db.update(
            _db.workouts,
          )..where((w) => w.id.equals(workout.id))).write(
            db.WorkoutsCompanion(
              status: const Value(_completed),
              updatedAt: Value(DateTime.now()),
            ),
          );

      if (updated == 0) {
        await _insertTree(workout, status: _completed);
      }
    });
  }

  @override
  Future<List<Workout>> loadHistory() async {
    final rows =
        await (_db.select(_db.workouts)
              ..where((w) => w.status.equals(_completed) & w.deletedAt.isNull())
              ..orderBy([(w) => OrderingTerm.desc(w.date)]))
            .get();

    return Future.wait(rows.map(_hydrate));
  }

  @override
  Future<void> deleteWorkout(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.workouts)..where((w) => w.id.equals(id))).write(
      db.WorkoutsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  Future<void> _insertTree(Workout workout, {required String status}) async {
    await _db
        .into(_db.workouts)
        .insert(
          db.WorkoutsCompanion.insert(
            id: workout.id,
            name: workout.name,
            date: workout.date,
            createdAt: workout.createdAt,
            updatedAt: workout.updatedAt,
            status: Value(status),
          ),
        );

    for (var i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      final templateId = await _resolveTemplateId(exercise.name);

      await _db
          .into(_db.exercises)
          .insert(
            db.ExercisesCompanion.insert(
              id: exercise.id,
              workoutId: workout.id,
              templateId: Value(templateId),
              name: exercise.name,
              position: i,
            ),
          );

      for (var j = 0; j < exercise.sets.length; j++) {
        final set = exercise.sets[j];
        await _db
            .into(_db.workoutSets)
            .insert(
              db.WorkoutSetsCompanion.insert(
                id: set.id,
                exerciseId: exercise.id,
                weight: set.weight,
                reps: set.reps,
                rir: set.rir,
                position: j,
              ),
            );
      }
    }
  }

  Future<String> _resolveTemplateId(String name) async {
    final trimmed = name.trim();
    final normalized = trimmed.toLowerCase();

    final existing =
        await (_db.select(_db.exerciseTemplates)..where(
              (t) => t.normalizedName.equals(normalized) & t.deletedAt.isNull(),
            ))
            .getSingleOrNull();

    if (existing != null) return existing.id;

    final id = const Uuid().v4();
    final now = DateTime.now();

    await _db
        .into(_db.exerciseTemplates)
        .insert(
          db.ExerciseTemplatesCompanion.insert(
            id: id,
            name: trimmed,
            normalizedName: normalized,
            createdAt: now,
            updatedAt: now,
          ),
        );

    return id;
  }

  Future<Workout> _hydrate(db.Workout row) async {
    final exerciseRows =
        await (_db.select(_db.exercises)
              ..where((e) => e.workoutId.equals(row.id))
              ..orderBy([(e) => OrderingTerm.asc(e.position)]))
            .get();

    final exercises = <Exercise>[];

    for (final exerciseRow in exerciseRows) {
      final setRows =
          await (_db.select(_db.workoutSets)
                ..where((s) => s.exerciseId.equals(exerciseRow.id))
                ..orderBy([(s) => OrderingTerm.asc(s.position)]))
              .get();

      exercises.add(
        Exercise(
          id: exerciseRow.id,
          name: exerciseRow.name,
          sets: setRows
              .map(
                (s) => WorkoutSet(
                  id: s.id,
                  weight: s.weight,
                  reps: s.reps,
                  rir: s.rir,
                ),
              )
              .toList(),
        ),
      );
    }

    return Workout(
      id: row.id,
      name: row.name,
      date: row.date,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      exercises: exercises,
    );
  }
}
