import 'package:flutter/material.dart';
import 'package:virtus_app/models/routine.dart';
import 'package:virtus_app/models/workout.dart';
import 'package:virtus_app/repositories/routine_repository.dart';
import 'package:virtus_app/repositories/settings_repository.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';
import 'package:virtus_app/repositories/workout_repository.dart';
import 'package:virtus_app/screens/history_screen.dart';
import 'package:virtus_app/screens/routines_screen.dart';
import 'package:virtus_app/screens/settings_screen.dart';
import 'package:virtus_app/screens/statistics_view.dart';
import 'package:virtus_app/screens/workout_view.dart';
import 'package:virtus_app/state/workout_controller.dart';
import 'package:virtus_app/widgets/app_app_bar.dart';
import 'package:virtus_app/widgets/goals_dashboard.dart';
import 'package:virtus_app/widgets/today_plan_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.statisticsRepository,
    required this.settingsRepository,
    required this.routineRepository,
    this.initialWorkout,
  });

  final WorkoutRepository repository;
  final StatisticsRepository statisticsRepository;
  final SettingsRepository settingsRepository;
  final RoutineRepository routineRepository;
  final Workout? initialWorkout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeSection _section = HomeSection.home;
  int _goalsRevision = 0;
  int _exerciseRevision = 0;

  late final WorkoutController _controller = WorkoutController(
    workout: widget.initialWorkout,
    repository: widget.repository,
  );

  void _selectSection(HomeSection section) {
    setState(() => _section = section);
  }

  void _templatesChanged() {
    if (!mounted) return;
    setState(() => _exerciseRevision++);
  }

  void _goalsChanged() {
    if (!mounted) return;
    setState(() => _goalsRevision++);
  }

  Future<void> _finishWorkout() async {
    final saved = await _controller.finishWorkout();
    if (!mounted) return;
    setState(() => _goalsRevision++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved ? 'Workout saved to history' : 'Could not save workout',
        ),
      ),
    );
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HistoryScreen(repository: widget.repository),
      ),
    );
  }

  Future<void> _openRoutines() {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoutinesScreen(
          repository: widget.routineRepository,
          statisticsRepository: widget.statisticsRepository,
          onTemplatesChanged: _templatesChanged,
        ),
      ),
    );
  }

  Future<void> _saveAsRoutine() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _RoutineNameDialog(),
    );

    if (name == null || name.isEmpty) return;

    await widget.routineRepository.saveRoutine(
      Routine(
        name: name,
        exercises: _controller.exercises
            .map(
              (e) => RoutineExercise(
                name: e.name,
                setCount: e.sets.isEmpty ? 1 : e.sets.length,
              ),
            )
            .toList(),
      ),
    );
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Saved as routine "$name"')));
  }

  Future<void> _startRoutine() async {
    final routines = await widget.routineRepository.loadRoutines();
    if (!mounted) return;

    if (routines.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No routines yet')));
      return;
    }

    final routine = await showModalBottomSheet<Routine>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          children: [
            for (final saved in routines)
              ListTile(
                key: ValueKey('start-routine-${saved.name}'),
                title: Text(saved.name),
                subtitle: Text('${saved.exercises.length} exercises'),
                onTap: () => Navigator.of(context).pop(saved),
              ),
          ],
        ),
      ),
    );
    if (routine == null) return;

    _controller.startRoutine(routine);
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Started ${routine.name}')));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppAppBar(
            section: _section,
            onSectionChanged: _selectSection,
            onFinish: _controller.exercises.isEmpty ? null : _finishWorkout,
            onHistory: _openHistory,
            onRoutines: _openRoutines,
          ),
          body: IndexedStack(
            index: _section.index,
            children: [
              Column(
                children: [
                  TodayPlanCard(
                    exercises: _controller.exercises,
                    date: _controller.workout.date,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('start-routine-button'),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start routine'),
                            onPressed: _startRoutine,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('save-as-routine-button'),
                            icon: const Icon(Icons.bookmark_add),
                            label: const Text('Save as routine'),
                            onPressed: _saveAsRoutine,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GoalsDashboard(
                    repository: widget.statisticsRepository,
                    settingsRepository: widget.settingsRepository,
                    revision: _goalsRevision,
                  ),
                  Expanded(
                    child: WorkoutView(
                      controller: _controller,
                      statisticsRepository: widget.statisticsRepository,
                      onTemplatesChanged: _templatesChanged,
                    ),
                  ),
                ],
              ),
              StatisticsView(
                repository: widget.statisticsRepository,
                revision: _exerciseRevision,
              ),
              SettingsScreen(
                repository: widget.settingsRepository,
                onGoalsSaved: _goalsChanged,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoutineNameDialog extends StatefulWidget {
  const _RoutineNameDialog();

  @override
  State<_RoutineNameDialog> createState() => _RoutineNameDialogState();
}

class _RoutineNameDialogState extends State<_RoutineNameDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save as routine'),
      content: TextField(
        key: const Key('routine-name-field'),
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Routine name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('save-as-routine-confirm'),
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
