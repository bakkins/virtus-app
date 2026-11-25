import 'package:flutter/material.dart';
import 'package:virtus_app/models/exercise.dart';

class TodayPlanCard extends StatelessWidget {
  const TodayPlanCard({super.key, required this.exercises, required this.date});

  final List<Exercise> exercises;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text("Today's plan", style: textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (exercises.isEmpty)
              const Text('No exercises planned yet')
            else
              ...exercises.map(
                (exercise) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.fitness_center, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(exercise.name)),
                      Text(
                        '${exercise.sets.length} '
                        '${exercise.sets.length == 1 ? 'set' : 'sets'}',
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
