import 'package:flutter/material.dart';
import 'package:virtus_app/models/workout.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';
import 'package:virtus_app/repositories/workout_repository.dart';
import 'package:virtus_app/screens/history_screen.dart';
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
    this.initialWorkout,
  });

  final WorkoutRepository repository;
  final StatisticsRepository statisticsRepository;
  final Workout? initialWorkout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeSection _section = HomeSection.home;
  int _goalsRevision = 0;

  late final WorkoutController _controller = WorkoutController(
    workout: widget.initialWorkout,
    repository: widget.repository,
  );

  void _selectSection(HomeSection section) {
    setState(() => _section = section);
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
                  GoalsDashboard(
                    repository: widget.statisticsRepository,
                    revision: _goalsRevision,
                  ),
                  Expanded(
                    child: WorkoutView(
                      controller: _controller,
                      statisticsRepository: widget.statisticsRepository,
                    ),
                  ),
                ],
              ),
              StatisticsView(repository: widget.statisticsRepository),
              const SettingsScreen(),
            ],
          ),
        );
      },
    );
  }
}
