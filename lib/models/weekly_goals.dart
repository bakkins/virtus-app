class WeeklyGoals {
  const WeeklyGoals({required this.workouts, this.volume});

  final int workouts;
  final double? volume;

  static const WeeklyGoals defaultGoals = WeeklyGoals(workouts: 3);
}
