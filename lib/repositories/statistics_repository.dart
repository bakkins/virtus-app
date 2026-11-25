import 'package:drift/drift.dart';
import 'package:virtus_app/data/database.dart';

class SavedExercise {
  const SavedExercise({required this.id, required this.name, this.category});

  final String id;
  final String name;
  final String? category;
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
  Future<List<SetProgress>> exerciseHistory(String templateId);
  Future<List<WeeklyVolume>> weeklyVolume({int weeks = 12});
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

    return rows
        .map((r) => SavedExercise(id: r.id, name: r.name, category: r.category))
        .toList();
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

  DateTime _startOfWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }
}
