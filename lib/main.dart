import 'package:flutter/material.dart';
import 'package:virtus_app/data/database.dart' as db;
import 'package:virtus_app/models/workout.dart';
import 'package:virtus_app/repositories/drift_workout_repository.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';
import 'package:virtus_app/repositories/workout_repository.dart';
import 'package:virtus_app/screens/workout_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = db.AppDatabase();
  final repository = DriftWorkoutRepository(database);
  final statisticsRepository = DriftStatisticsRepository(database);
  final workout = await repository.loadCurrent();

  runApp(
    MainApp(
      repository: repository,
      statisticsRepository: statisticsRepository,
      initialWorkout: workout,
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
    required this.repository,
    required this.statisticsRepository,
    this.initialWorkout,
  });

  final WorkoutRepository repository;
  final StatisticsRepository statisticsRepository;
  final Workout? initialWorkout;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WorkoutScreen(
        repository: repository,
        statisticsRepository: statisticsRepository,
        initialWorkout: initialWorkout,
      ),
    );
  }
}
