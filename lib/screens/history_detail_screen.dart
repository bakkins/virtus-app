import 'package:flutter/material.dart';
import 'package:virtus_app/models/workout.dart';

class HistoryDetailScreen extends StatelessWidget {
  final Workout workout;

  const HistoryDetailScreen({super.key, required this.workout});

  String _weightText(double value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toString();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final date = MaterialLocalizations.of(context).formatMediumDate(workout.date);

    return Scaffold(
      appBar: AppBar(title: Text(workout.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(date, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          for (final exercise in workout.exercises)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: colorScheme.surfaceContainerHighest,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (int i = 0; i < exercise.sets.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '${i + 1}. ${_weightText(exercise.sets[i].weight)} kg × '
                        '${exercise.sets[i].reps} reps @ RIR ${exercise.sets[i].rir}',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}