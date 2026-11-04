import 'package:flutter/material.dart';
import 'package:virtus_app/models/workout.dart';
import 'package:virtus_app/repositories/local_workout_repository.dart';
import 'package:virtus_app/screens/workout_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = LocalWorkoutRepository();
  final workout = await repository.loadCurrent();
  runApp(MainApp(repository: repository, initialWorkout: workout));
}

class MainApp extends StatelessWidget {
  final LocalWorkoutRepository repository;
  final Workout? initialWorkout;

  const MainApp({
    super.key,
    required this.repository,
    this.initialWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WorkoutScreen(
        repository: repository,
        initialWorkout: initialWorkout,
      ),
    );
  }
}
