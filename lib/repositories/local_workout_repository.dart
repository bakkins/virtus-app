import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtus_app/models/workout.dart';
import 'package:virtus_app/repositories/workout_repository.dart';

class LocalWorkoutRepository implements WorkoutRepository {
  static const String _currentWorkoutKey = 'current_workout';

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
}