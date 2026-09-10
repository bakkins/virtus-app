import 'package:flutter/widget_previews.dart'; // tikai prieks preview 
import 'package:flutter/material.dart';

class WorkoutScreen extends StatelessWidget {
  @Preview() // tikai prieks preview 
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text("Workout"),
      ),
    );
  }
}