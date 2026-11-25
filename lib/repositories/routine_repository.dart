import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:virtus_app/data/database.dart' as db;
import 'package:virtus_app/models/routine.dart';

abstract class RoutineRepository {
  Future<List<Routine>> loadRoutines();
  Future<void> saveRoutine(Routine routine);
  Future<void> deleteRoutine(String id);
}

class DriftRoutineRepository implements RoutineRepository {
  DriftRoutineRepository(this._db);

  final db.AppDatabase _db;

  @override
  Future<List<Routine>> loadRoutines() async {
    final rows =
        await (_db.select(_db.routines)
              ..where((r) => r.deletedAt.isNull())
              ..orderBy([(r) => OrderingTerm.asc(r.name)]))
            .get();

    return Future.wait(rows.map(_hydrate));
  }

  @override
  Future<void> saveRoutine(Routine routine) async {
    final name = routine.name.trim();
    if (name.isEmpty) return;

    await _db.transaction(() async {
      final existing = await (_db.select(
        _db.routines,
      )..where((r) => r.id.equals(routine.id))).getSingleOrNull();

      if (existing == null) {
        await _db
            .into(_db.routines)
            .insert(
              db.RoutinesCompanion.insert(
                id: routine.id,
                name: name,
                createdAt: routine.createdAt,
                updatedAt: DateTime.now(),
              ),
            );
      } else {
        await (_db.update(
          _db.routines,
        )..where((r) => r.id.equals(routine.id))).write(
          db.RoutinesCompanion(
            name: Value(name),
            updatedAt: Value(DateTime.now()),
            deletedAt: const Value<DateTime?>(null),
          ),
        );
      }

      await (_db.delete(
        _db.routineExercises,
      )..where((e) => e.routineId.equals(routine.id))).go();

      for (var i = 0; i < routine.exercises.length; i++) {
        final exercise = routine.exercises[i];
        await _db
            .into(_db.routineExercises)
            .insert(
              db.RoutineExercisesCompanion.insert(
                id: exercise.id,
                routineId: routine.id,
                templateId: Value(await _resolveTemplateId(exercise)),
                name: exercise.name,
                position: i,
                setCount: Value(exercise.setCount < 1 ? 1 : exercise.setCount),
              ),
            );
      }
    });
  }

  @override
  Future<void> deleteRoutine(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.routines)..where((r) => r.id.equals(id))).write(
      db.RoutinesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  Future<String?> _resolveTemplateId(RoutineExercise exercise) async {
    if (exercise.templateId != null) return exercise.templateId;

    final name = exercise.name.trim();
    if (name.isEmpty) return null;

    final normalized = name.toLowerCase();
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
            name: name,
            normalizedName: normalized,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<Routine> _hydrate(db.Routine row) async {
    final exerciseRows =
        await (_db.select(_db.routineExercises)
              ..where((e) => e.routineId.equals(row.id))
              ..orderBy([(e) => OrderingTerm.asc(e.position)]))
            .get();

    return Routine(
      id: row.id,
      name: row.name,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      exercises: exerciseRows
          .map(
            (e) => RoutineExercise(
              id: e.id,
              name: e.name,
              setCount: e.setCount,
              templateId: e.templateId,
            ),
          )
          .toList(),
    );
  }
}
