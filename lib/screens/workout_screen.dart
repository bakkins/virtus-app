import 'package:flutter/material.dart';
import 'package:virtus_app/models/workout.dart';
import 'package:virtus_app/repositories/workout_repository.dart';
import 'package:virtus_app/state/workout_controller.dart';
import 'package:virtus_app/widgets/add_exercise_bottom_sheet.dart';
import 'package:virtus_app/widgets/exercise_widget.dart';

class WorkoutScreen extends StatefulWidget {
  final WorkoutRepository repository;
  final Workout? initialWorkout;
  const WorkoutScreen({
    super.key,
    required this.repository,
    this.initialWorkout,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late final WorkoutController _controller = WorkoutController(
    workout: widget.initialWorkout,
    repository: widget.repository,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.exercises.isEmpty) {
            return const Center(
              child: Text('Tap + to add your first exercise'),
            );
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            buildDefaultDragHandles: false,
            itemCount: _controller.exercises.length,
            onReorderItem: _controller.reorderExercises,
            itemBuilder: (context, i) {
              final exercise = _controller.exercises[i];
              return ExerciseWidget(
                key: ObjectKey(exercise),
                exercise: exercise,
                controller: _controller,
                index: i,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExerciseSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openAddExerciseSheet() async {
    final String? name = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => const AddExerciseBottomSheet(),
    );
    if (name == null || name.isEmpty) return;
    _controller.addExercise(name);
  }
}
