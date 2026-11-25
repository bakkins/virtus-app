import 'package:flutter/material.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';
import 'package:virtus_app/state/workout_controller.dart';
import 'package:virtus_app/widgets/add_exercise_bottom_sheet.dart';
import 'package:virtus_app/widgets/exercise_widget.dart';

class WorkoutView extends StatefulWidget {
  const WorkoutView({
    super.key,
    required this.controller,
    required this.statisticsRepository,
  });

  final WorkoutController controller;
  final StatisticsRepository statisticsRepository;

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final exercises = widget.controller.exercises;

        return Stack(
          children: [
            exercises.isEmpty
                ? const Center(child: Text('Tap + to add your first exercise'))
                : ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    buildDefaultDragHandles: false,
                    itemCount: exercises.length,
                    onReorderItem: widget.controller.reorderExercises,
                    itemBuilder: (context, i) {
                      final exercise = exercises[i];
                      return ExerciseWidget(
                        key: ObjectKey(exercise),
                        exercise: exercise,
                        controller: widget.controller,
                        index: i,
                      );
                    },
                  ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                key: const Key('add-exercise-button'),
                onPressed: _openAddExerciseSheet,
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openAddExerciseSheet() async {
    final String? name = await showModalBottomSheet<String>(
      context: context,
      builder: (context) =>
          AddExerciseBottomSheet(repository: widget.statisticsRepository),
    );
    if (name == null || name.isEmpty) return;
    widget.controller.addExercise(name);
  }
}
