import 'package:flutter/material.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';

enum ActivityMetric { workouts, volume }

class ProgressChart extends StatelessWidget {
  const ProgressChart({
    super.key,
    required this.activity,
    required this.metric,
    required this.title,
    required this.formatter,
  });

  final List<WeeklyActivity> activity;
  final ActivityMetric metric;
  final String title;
  final String Function(double value) formatter;

  double _value(WeeklyActivity item) => metric == ActivityMetric.workouts
      ? item.workouts.toDouble()
      : item.volume;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = activity.map(_value).toList();
    final peak = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    final scale = peak <= 0 ? 1.0 : peak;
    final color = metric == ActivityMetric.workouts
        ? theme.colorScheme.primary
        : theme.colorScheme.tertiary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  metric == ActivityMetric.workouts
                      ? Icons.fitness_center
                      : Icons.monitor_weight,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            if (activity.isEmpty)
              const Text('No activity yet')
            else
              SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < activity.length; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                formatter(values[i]),
                                key: Key('activity-${metric.name}-value-$i'),
                                style: theme.textTheme.labelSmall,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                key: Key('activity-${metric.name}-bar-$i'),
                                height: 4 + (values[i] / scale) * 70,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${activity[i].weekStart.day}/'
                                '${activity[i].weekStart.month}',
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
