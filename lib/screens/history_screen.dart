import 'package:flutter/material.dart';
import 'package:virtus_app/models/workout.dart';
import 'package:virtus_app/repositories/workout_repository.dart';
import 'package:virtus_app/screens/history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final WorkoutRepository repository;

  const HistoryScreen({super.key, required this.repository});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final Future<List<Workout>> _history = widget.repository.loadHistory();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: FutureBuilder<List<Workout>>(
        future: _history,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load history'));
          }
          final workouts = snapshot.data ?? const <Workout>[];
          if (workouts.isEmpty) {
            return const Center(child: Text('No finished workouts yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workouts.length,
            itemBuilder: (context, i) => _HistoryTile(workout: workouts[i]),
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Workout workout;

  const _HistoryTile({required this.workout});

  String _volumeText(double value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final date = MaterialLocalizations.of(context).formatMediumDate(workout.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(workout.name),
        subtitle: Text(
          '$date · ${workout.exercises.length} exercises · '
          '${workout.totalSets} sets · ${_volumeText(workout.totalVolume)} kg',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HistoryDetailScreen(workout: workout),
          ),
        ),
      ),
    );
  }
}