import 'package:flutter/material.dart';
import 'package:virtus_app/models/weekly_goals.dart';
import 'package:virtus_app/repositories/settings_repository.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';

class GoalsDashboard extends StatefulWidget {
  const GoalsDashboard({
    super.key,
    required this.repository,
    required this.settingsRepository,
    this.revision = 0,
  });

  final StatisticsRepository repository;
  final SettingsRepository settingsRepository;
  final int revision;

  @override
  State<GoalsDashboard> createState() => _GoalsDashboardState();
}

class _GoalsDashboardState extends State<GoalsDashboard> {
  WeeklyGoals _goals = WeeklyGoals.defaultGoals;
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
        oldWidget.repository != widget.repository ||
        oldWidget.settingsRepository != widget.settingsRepository) {
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final goals = await widget.settingsRepository.loadGoals();
      final workouts = await widget.repository.workoutsThisWeek();
      final volume = await widget.repository.volumeThisWeek();
      if (!mounted) return;
      setState(() {
        _goals = goals;
        _workouts = workouts;
        _volume = volume;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  double _progress(double current, double goal) {
    if (goal <= 0) return 0;
    return (current / goal).clamp(0.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final volumeGoal = _goals.volume;

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
              label: 'Completed workouts',
              display: '$_workouts / ${_goals.workouts}',
              progress: _loading
                  ? 0
                  : _progress(_workouts.toDouble(), _goals.workouts.toDouble()),
            ),
            if (volumeGoal != null) ...[
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
