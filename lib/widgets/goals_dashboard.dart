import 'package:flutter/material.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';

class GoalsDashboard extends StatefulWidget {
  const GoalsDashboard({
    super.key,
    required this.repository,
    this.revision = 0,
  });

  final StatisticsRepository repository;
  final int revision;

  @override
  State<GoalsDashboard> createState() => _GoalsDashboardState();
}

class _GoalsDashboardState extends State<GoalsDashboard> {
  static const int workoutGoal = 3;
  static const double volumeGoal = 5000;

  int _workouts = 0;
  double _volume = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(GoalsDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revision != widget.revision ||
        oldWidget.repository != widget.repository) {
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final workouts = await widget.repository.workoutsThisWeek();
      final volume = await widget.repository.volumeThisWeek();
      if (!mounted) return;
      setState(() {
        _workouts = workouts;
        _volume = volume;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  double _progress(double current, double goal) =>
      (current / goal).clamp(0.0, 1.0).toDouble();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, size: 18),
                const SizedBox(width: 8),
                Text('Weekly goals', style: textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            _ProgressRow(
              icon: Icons.fitness_center,
              label: 'Workouts',
              display: '$_workouts / $workoutGoal',
              progress: _loading
                  ? 0
                  : _progress(_workouts.toDouble(), workoutGoal.toDouble()),
            ),
            const SizedBox(height: 12),
            _ProgressRow(
              icon: Icons.monitor_weight,
              label: 'Volume',
              display:
                  '${_volume.toStringAsFixed(0)} / '
                  '${volumeGoal.toStringAsFixed(0)} kg',
              progress: _loading ? 0 : _progress(_volume, volumeGoal),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.icon,
    required this.label,
    required this.display,
    required this.progress,
  });

  final IconData icon;
  final String label;
  final String display;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label),
                  Text(display, style: const TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: progress, minHeight: 8),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
