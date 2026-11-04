import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtus_app/models/workout.dart';
import 'package:virtus_app/repositories/workout_repository.dart';

class LocalWorkoutRepository implements WorkoutRepository {
  static const String _currentWorkoutKey = 'current_workout';
  static const String _historyIdsKey = 'history_ids';

  String _workoutKey(String id) => 'workout_$id';

  @override
  Future<Workout?> loadCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_currentWorkoutKey);
    if (raw == null) return null;
    try {
      return Workout.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCurrent(Workout workout) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentWorkoutKey, jsonEncode(workout.toJson()));
  }

  @override
  Future<void> saveWorkout(Workout workout) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_workoutKey(workout.id), jsonEncode(workout.toJson()));

    final ids = prefs.getStringList(_historyIdsKey) ?? <String>[];
    if (!ids.contains(workout.id)) {
      await prefs.setStringList(_historyIdsKey, [workout.id, ...ids]);
    }
  }

  @override
  Future<List<Workout>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_historyIdsKey) ?? <String>[];

    final workouts = <Workout>[];
    for (final id in ids) {
      final raw = prefs.getString(_workoutKey(id));
      if (raw == null) continue; // dead index entry — skip
      try {
        workouts.add(Workout.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      } catch (_) {
        // corrupt entry — skip instead of breaking the whole list
      }
    }
    return workouts;
  }

   @override
  Future<void> deleteWorkout(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_workoutKey(id));

    final ids = prefs.getStringList(_historyIdsKey) ?? <String>[];
    final updatedIds = ids.where((historyId) => historyId != id).toList();
    await prefs.setStringList(_historyIdsKey, updatedIds);
  }
}
