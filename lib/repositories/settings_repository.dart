import 'package:virtus_app/data/database.dart';
import 'package:virtus_app/models/weekly_goals.dart';

abstract class SettingsRepository {
  Future<WeeklyGoals> loadGoals();
  Future<void> saveGoals(WeeklyGoals goals);
}

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);

  final AppDatabase _db;

  static const _workoutsKey = 'weekly_workouts_goal';
  static const _volumeKey = 'weekly_volume_goal';

  @override
  Future<WeeklyGoals> loadGoals() async {
    final rows = await (_db.select(
      _db.appSettings,
    )..where((t) => t.key.isIn([_workoutsKey, _volumeKey]))).get();
    final values = {for (final row in rows) row.key: row.value};

    final parsedWorkouts = int.tryParse(values[_workoutsKey] ?? '');
    final parsedVolume = double.tryParse(values[_volumeKey] ?? '');

    return WeeklyGoals(
      workouts: parsedWorkouts != null && parsedWorkouts > 0
          ? parsedWorkouts
          : WeeklyGoals.defaultGoals.workouts,
      volume: parsedVolume != null && parsedVolume > 0 ? parsedVolume : null,
    );
  }

  @override
  Future<void> saveGoals(WeeklyGoals goals) async {
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: _workoutsKey,
            value: goals.workouts.toString(),
          ),
        );

    if (goals.volume == null) {
      await (_db.delete(
        _db.appSettings,
      )..where((t) => t.key.equals(_volumeKey))).go();
      return;
    }

    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: _volumeKey,
            value: goals.volume.toString(),
          ),
        );
  }
}
