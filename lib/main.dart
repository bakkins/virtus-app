import 'package:flutter/material.dart';
import 'package:virtus_app/data/database.dart' as db;
import 'package:virtus_app/models/workout.dart';
import 'package:virtus_app/repositories/drift_workout_repository.dart';
import 'package:virtus_app/repositories/routine_repository.dart';
import 'package:virtus_app/repositories/settings_repository.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';
import 'package:virtus_app/repositories/workout_repository.dart';
import 'package:virtus_app/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = db.AppDatabase();
  final repository = DriftWorkoutRepository(database);
  final statisticsRepository = DriftStatisticsRepository(database);
  final settingsRepository = DriftSettingsRepository(database);
  final routineRepository = DriftRoutineRepository(database);
  final workout = await repository.loadCurrent();

  runApp(
    MainApp(
      repository: repository,
      statisticsRepository: statisticsRepository,
      settingsRepository: settingsRepository,
      routineRepository: routineRepository,
      initialWorkout: workout,
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
    required this.repository,
    required this.statisticsRepository,
    required this.settingsRepository,
    required this.routineRepository,
    this.initialWorkout,
  });

  final WorkoutRepository repository;
  final StatisticsRepository statisticsRepository;
  final SettingsRepository settingsRepository;
  final RoutineRepository routineRepository;
  final Workout? initialWorkout;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(
        repository: repository,
        statisticsRepository: statisticsRepository,
        settingsRepository: settingsRepository,
        routineRepository: routineRepository,
        initialWorkout: initialWorkout,
      ),
    );
  }
}
