import 'package:flutter/material.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key, required this.repository});

  final StatisticsRepository repository;

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  late Future<List<SavedExercise>> _saved;
  late Future<List<WeeklyVolume>> _weekly;
  Future<List<SetProgress>> _history = Future.value(const <SetProgress>[]);
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _saved = widget.repository.savedExercises();
    _weekly = widget.repository.weeklyVolume();

    _saved.then((items) {
      if (items.isEmpty || !mounted) return;
      setState(() {
        _selectedId = items.first.id;
        _history = widget.repository.exerciseHistory(items.first.id);
      });
    });
  }

  void _select(String id) {
    setState(() {
      _selectedId = id;
      _history = widget.repository.exerciseHistory(id);
    });
  }

  String _format(double value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SavedExercise>>(
      future: _saved,
      builder: (context, savedSnapshot) {
        if (savedSnapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final saved = savedSnapshot.data ?? const <SavedExercise>[];
        if (saved.isEmpty) {
          return const Center(child: Text('No exercises saved yet'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedId,
              decoration: const InputDecoration(
                labelText: 'Exercise',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Select exercise'),
              items: saved
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e.id,
                      child: Text(e.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) _select(value);
              },
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<SetProgress>>(
              future: _history,
              builder: (context, historySnapshot) {
                if (historySnapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final history = historySnapshot.data ?? const <SetProgress>[];

                if (history.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No sets logged for this exercise yet'),
                    ),
                  );
                }

                final best = history
                    .map((s) => s.estimatedOneRm)
                    .reduce((a, b) => a > b ? a : b);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Best set: ${_format(best)} kg e1RM',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    ...history.map(
                      (s) => ListTile(
                        title: Text(
                          '${_format(s.weight)} kg × ${s.reps} @ RIR ${s.rir}',
                        ),
                        subtitle: Text(s.workoutName),
                        trailing: Text(_format(s.volume)),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Weekly volume',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<WeeklyVolume>>(
              future: _weekly,
              builder: (context, weeklySnapshot) {
                final weekly = weeklySnapshot.data ?? const <WeeklyVolume>[];

                if (weekly.isEmpty) {
                  return const Text('No volume data yet');
                }

                return Column(
                  children: weekly
                      .map(
                        (w) => ListTile(
                          title: Text(
                            '${w.weekStart.day}/${w.weekStart.month}',
                          ),
                          trailing: Text('${_format(w.volume)} kg'),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
