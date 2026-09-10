import 'package:flutter/widget_previews.dart'; // tikai prieks preview
import 'package:flutter/material.dart';
import '../widgets/exercise_widget.dart';

class WorkoutScreen extends StatelessWidget {
  @Preview() // tikai prieks preview
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Workout")),
      body: const ExerciseWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Add exercise");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
