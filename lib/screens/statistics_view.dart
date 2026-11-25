import 'package:flutter/material.dart';
import 'package:virtus_app/repositories/settings_repository.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';
import 'package:virtus_app/widgets/goals_dashboard.dart';
import 'package:virtus_app/widgets/progress_chart.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({
    super.key,
    required this.repository,
    required this.settingsRepository,
    this.revision = 0,
    this.goalsRevision = 0,
  });

  final StatisticsRepository repository;
  final SettingsRepository settingsRepository;
  final int revision;
  final int goalsRevision;

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  late Future<List<SavedExercise>> _saved;
  late Future<List<WeeklyActivity>> _activity;
  late Future<List<PersonalRecord>> _records;
  Future<List<SetProgress>> _history = Future.value(const <SetProgress>[]);
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _saved = widget.repository.savedExercises();
    _activity = widget.repository.weeklyActivity();
    _records = widget.repository.personalRecords();
    _watchSaved();
  }

  @override
  void didUpdateWidget(StatisticsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revision != widget.revision ||
        oldWidget.goalsRevision != widget.goalsRevision ||
        oldWidget.repository != widget.repository) {
      final saved = widget.repository.savedExercises();
      final activity = widget.repository.weeklyActivity();
      final records = widget.repository.personalRecords();
      setState(() {
        _saved = saved;
        _activity = activity;
        _records = records;
      });
      _watchSaved();
    }
  }

  void _watchSaved() {
    _saved.then((items) {
      if (!mounted) return;
      setState(() {
        _selectedId = items.isEmpty ? null : items.first.id;
        _history = _selectedId == null
            ? Future.value(const <SetProgress>[])
            : widget.repository.exerciseHistory(_selectedId!);
      });
    });
  }

  void _select(String id) {
    setState(() {
      _selectedId = id;
      _history = widget.repository.exerciseHistory(id);
    });
  }

  void _refreshRecords() {
    if (!mounted) return;
    setState(() {
      _records = widget.repository.personalRecords();
    });
  }

  Future<void> _setPrMetric(String templateId, int repCount) async {
    await widget.repository.setExercisePrRepCount(templateId, repCount);
    _refreshRecords();
  }

  Future<void> _logPr(String templateId, int initialRepCount) async {
    final input = await showDialog<({int repCount, double weight})>(
      context: context,
      builder: (context) => _ManualPrDialog(initialRepCount: initialRepCount),
    );
    if (input == null) return;

    await widget.repository.addManualPr(
      templateId: templateId,
      repCount: input.repCount,
      weight: input.weight,
    );
    _refreshRecords();
  }

  Future<void> _removeManualPr(String id) async {
    await widget.repository.deleteManualPr(id);
    _refreshRecords();
  }

  Widget _buildPrCard(
    BuildContext context,
    int index,
    PersonalRecord record,
    TextTheme textTheme,
  ) {
    final manual = record.manualPr;

    return Card(
      key: ValueKey('personal-record-${record.templateId}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.exerciseName,
                    style: textTheme.titleMedium,
                  ),
                ),
                ChoiceChip(
                  key: ValueKey('pr-metric-1-$index'),
                  label: const Text('1RM'),
                  selected: record.repCount == 1,
                  onSelected: (_) => _setPrMetric(record.templateId, 1),
                ),
                const SizedBox(width: 4),
                ChoiceChip(
                  key: ValueKey('pr-metric-5-$index'),
                  label: const Text('5RM'),
                  selected: record.repCount == 5,
                  onSelected: (_) => _setPrMetric(record.templateId, 5),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Best set: ${_format(record.bestWeight)} kg × '
              '${record.bestReps} @ RIR ${record.bestRir}',
            ),
            const SizedBox(height: 4),
            Text(
              '${_format(record.bestValue)} kg ${record.metricLabel} '
              '(estimated) · ${_date(record.date)} · '
              '${record.setCount} sets logged',
              style: textTheme.bodySmall,
            ),
            if (manual != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Manual ${manual.repCount}RM: '
                      '${_format(manual.weight)} kg · ${_date(manual.date)}',
                    ),
                  ),
                  IconButton(
                    key: ValueKey('delete-pr-button-$index'),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete manual PR',
                    onPressed: () => _removeManualPr(manual.id),
                  ),
                ],
              ),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                key: ValueKey('log-pr-button-$index'),
                icon: const Icon(Icons.add),
                label: const Text('Log PR'),
                onPressed: () => _logPr(record.templateId, record.repCount),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _format(double value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);

  String _date(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<List<SavedExercise>>(
      future: _saved,
      builder: (context, savedSnapshot) {
        if (savedSnapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final saved = savedSnapshot.data ?? const <SavedExercise>[];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GoalsDashboard(
              repository: widget.repository,
              settingsRepository: widget.settingsRepository,
              revision: widget.goalsRevision,
            ),
            const SizedBox(height: 24),
            if (saved.isEmpty) ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No exercises saved yet'),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text('Progress', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            FutureBuilder<List<WeeklyActivity>>(
              future: _activity,
              builder: (context, snapshot) {
                final activity = snapshot.data ?? const <WeeklyActivity>[];
                return Column(
                  children: [
                    ProgressChart(
                      activity: activity,
                      metric: ActivityMetric.workouts,
                      title: 'Workouts per week',
                      formatter: (value) => value.toInt().toString(),
                    ),
                    const SizedBox(height: 12),
                    ProgressChart(
                      activity: activity,
                      metric: ActivityMetric.volume,
                      title: 'Volume per week (kg)',
                      formatter: _format,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text('Personal records', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            FutureBuilder<List<PersonalRecord>>(
              future: _records,
              builder: (context, snapshot) {
                final records = snapshot.data ?? const <PersonalRecord>[];
                if (records.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No personal records yet'),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final entry in records.asMap().entries)
                      _buildPrCard(context, entry.key, entry.value, textTheme),
                  ],
                );
              },
            ),
            if (saved.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Exercise history', style: textTheme.titleLarge),
              const SizedBox(height: 8),
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
                        child: Text('${e.name} · ${e.muscleGroup}'),
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

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...history.map(
                        (s) => ListTile(
                          title: Text(
                            '${_format(s.weight)} kg × ${s.reps} '
                            '@ RIR ${s.rir}',
                          ),
                          subtitle: Text('${_date(s.date)} · ${s.workoutName}'),
                          trailing: Text(_format(s.volume)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ManualPrDialog extends StatefulWidget {
  const _ManualPrDialog({required this.initialRepCount});

  final int initialRepCount;

  @override
  State<_ManualPrDialog> createState() => _ManualPrDialogState();
}

class _ManualPrDialogState extends State<_ManualPrDialog> {
  late int _repCount = widget.initialRepCount == 5 ? 5 : 1;
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final weight = double.tryParse(_controller.text.trim());
    if (weight == null || weight <= 0) {
      setState(() => _error = 'Enter a weight greater than zero');
      return;
    }
    Navigator.of(context).pop((repCount: _repCount, weight: weight));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log PR'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ChoiceChip(
                key: const Key('manual-pr-reps-1'),
                label: const Text('1RM'),
                selected: _repCount == 1,
                onSelected: (_) => setState(() => _repCount = 1),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                key: const Key('manual-pr-reps-5'),
                label: const Text('5RM'),
                selected: _repCount == 5,
                onSelected: (_) => setState(() => _repCount = 5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('manual-pr-weight-field'),
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Weight (kg)',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('manual-pr-save'),
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
