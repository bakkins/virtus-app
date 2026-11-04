import 'package:flutter/material.dart';
import 'package:virtus_app/models/workout.dart';
import 'package:virtus_app/repositories/workout_repository.dart';
import 'package:virtus_app/screens/history_screen.dart';
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
  @override
Widget build(BuildContext context) {
  return ListenableBuilder(
    listenable: _controller,
    builder: (context, _) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Workout'),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Finish workout',
              onPressed: _controller.exercises.isEmpty ? null : _finishWorkout,
            ),
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'History',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(repository: widget.repository),
                ),
              ),
            ),
          ],
        ),
        body: _controller.exercises.isEmpty
            ? const Center(child: Text('Tap + to add your first exercise'))
            : ReorderableListView.builder(
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
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddExerciseSheet,
          child: const Icon(Icons.add),
        ),
      );
    },
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

  Future<void> _finishWorkout() async {
  final saved = await _controller.finishWorkout();
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(saved ? 'Workout saved to history' : 'Could not save workout'),
    ),
  );
}
}
