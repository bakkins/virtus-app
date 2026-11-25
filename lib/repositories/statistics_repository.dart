import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:virtus_app/data/database.dart';

class SavedExercise {
  const SavedExercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
  });

  final String id;
  final String name;
  final String muscleGroup;
}

class SetProgress {
  const SetProgress({
    required this.date,
    required this.workoutName,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.rir,
  });

  final DateTime date;
  final String workoutName;
  final String exerciseName;
  final double weight;
  final int reps;
  final int rir;

  double get volume => weight * reps;
  double get estimatedOneRm => weight * (1 + reps / 30.0);
}

class WeeklyVolume {
  const WeeklyVolume({required this.weekStart, required this.volume});

  final DateTime weekStart;
  final double volume;
}

abstract class StatisticsRepository {
  Future<List<SavedExercise>> savedExercises();
  Future<void> ensureTemplate({
    required String name,
    required String muscleGroup,
  });
  Future<void> deleteTemplate(String id);
  Future<List<SetProgress>> exerciseHistory(String templateId);
  Future<List<WeeklyVolume>> weeklyVolume({int weeks = 12});
  Future<int> workoutsThisWeek();
  Future<double> volumeThisWeek();
}

class DriftStatisticsRepository implements StatisticsRepository {
  DriftStatisticsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<SavedExercise>> savedExercises() async {
    final rows =
        await (_db.select(_db.exerciseTemplates)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.name)]))
            .get();

    final items = rows
        .map(
          (r) => SavedExercise(
            id: r.id,
            name: r.name,
            muscleGroup: r.category ?? 'Custom',
          ),
        )
        .toList();

    items.sort((a, b) {
      final group = a.muscleGroup.compareTo(b.muscleGroup);
      return group != 0 ? group : a.name.compareTo(b.name);
    });
    return items;
  }

  @override
  Future<void> ensureTemplate({
    required String name,
    required String muscleGroup,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final normalized = trimmed.toLowerCase();
    final existing =
        await (_db.select(_db.exerciseTemplates)..where(
              (t) => t.normalizedName.equals(normalized) & t.deletedAt.isNull(),
            ))
            .getSingleOrNull();

    if (existing != null) {
      if (existing.category != muscleGroup) {
        await (_db.update(
          _db.exerciseTemplates,
        )..where((t) => t.id.equals(existing.id))).write(
          ExerciseTemplatesCompanion(
            category: Value(muscleGroup),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
      return;
    }

    final now = DateTime.now();
    await _db
        .into(_db.exerciseTemplates)
        .insert(
          ExerciseTemplatesCompanion.insert(
            id: const Uuid().v4(),
            name: trimmed,
            normalizedName: normalized,
            category: Value(muscleGroup),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  @override
  Future<void> deleteTemplate(String id) async {
    final now = DateTime.now();
    await (_db.update(
      _db.exerciseTemplates,
    )..where((t) => t.id.equals(id))).write(
      ExerciseTemplatesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  @override
  Future<List<SetProgress>> exerciseHistory(String templateId) async {
    final query =
        _db.select(_db.workoutSets).join([
            innerJoin(
              _db.exercises,
              _db.exercises.id.equalsExp(_db.workoutSets.exerciseId),
            ),
            innerJoin(
              _db.workouts,
              _db.workouts.id.equalsExp(_db.exercises.workoutId),
            ),
          ])
          ..where(
            _db.exercises.templateId.equals(templateId) &
                _db.workouts.deletedAt.isNull() &
                _db.workouts.status.equals('completed'),
          )
          ..orderBy([OrderingTerm.desc(_db.workouts.date)]);

    final rows = await query.get();

    return rows.map((row) {
      final set = row.readTable(_db.workoutSets);
      final exercise = row.readTable(_db.exercises);
      final workout = row.readTable(_db.workouts);

      return SetProgress(
        date: workout.date,
        workoutName: workout.name,
        exerciseName: exercise.name,
        weight: set.weight,
        reps: set.reps,
        rir: set.rir,
      );
    }).toList();
  }

  @override
  Future<List<WeeklyVolume>> weeklyVolume({int weeks = 12}) async {
    final query =
        _db.select(_db.workoutSets).join([
          innerJoin(
            _db.exercises,
            _db.exercises.id.equalsExp(_db.workoutSets.exerciseId),
          ),
          innerJoin(
            _db.workouts,
            _db.workouts.id.equalsExp(_db.exercises.workoutId),
          ),
        ])..where(
          _db.workouts.deletedAt.isNull() &
              _db.workouts.status.equals('completed'),
        );

    final rows = await query.get();
    final totals = <DateTime, double>{};

    for (final row in rows) {
      final set = row.readTable(_db.workoutSets);
      final workout = row.readTable(_db.workouts);
      final weekStart = _startOfWeek(workout.date);
      totals[weekStart] = (totals[weekStart] ?? 0) + set.weight * set.reps;
    }

    final cutoff = _startOfWeek(
      DateTime.now(),
    ).subtract(Duration(days: 7 * (weeks - 1)));

    return totals.entries
        .where((entry) => !entry.key.isBefore(cutoff))
        .map((entry) => WeeklyVolume(weekStart: entry.key, volume: entry.value))
        .toList()
      ..sort((a, b) => b.weekStart.compareTo(a.weekStart));
  }

  @override
  Future<int> workoutsThisWeek() async {
    final start = _startOfWeek(DateTime.now());
    final rows =
        await (_db.select(_db.workouts)..where(
              (w) =>
                  w.status.equals('completed') &
                  w.deletedAt.isNull() &
                  w.date.isBiggerOrEqualValue(start),
            ))
            .get();
    return rows.length;
  }

  @override
  Future<double> volumeThisWeek() async {
    final start = _startOfWeek(DateTime.now());
    final query =
        _db.select(_db.workoutSets).join([
          innerJoin(
            _db.exercises,
            _db.exercises.id.equalsExp(_db.workoutSets.exerciseId),
          ),
          innerJoin(
            _db.workouts,
            _db.workouts.id.equalsExp(_db.exercises.workoutId),
          ),
        ])..where(
          _db.workouts.status.equals('completed') &
              _db.workouts.deletedAt.isNull() &
              _db.workouts.date.isBiggerOrEqualValue(start),
        );

    final rows = await query.get();
    return rows.fold<double>(0, (total, row) {
      final set = row.readTable(_db.workoutSets);
      return total + set.weight * set.reps;
    });
  }

  DateTime _startOfWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }
}
