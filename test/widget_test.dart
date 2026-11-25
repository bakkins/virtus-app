import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtus_app/data/database.dart';
import 'package:virtus_app/main.dart';
import 'package:virtus_app/repositories/drift_workout_repository.dart';
import 'package:virtus_app/repositories/routine_repository.dart';
import 'package:virtus_app/repositories/settings_repository.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';
import 'package:virtus_app/widgets/today_plan_card.dart';

void main() {
  Future<AppDatabase> pumpApp(WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      MainApp(
        repository: DriftWorkoutRepository(database),
        statisticsRepository: DriftStatisticsRepository(database),
        settingsRepository: DriftSettingsRepository(database),
        routineRepository: DriftRoutineRepository(database),
      ),
    );
    await tester.pumpAndSettle();
    return database;
  }

  Future<void> openSection(WidgetTester tester, String section) async {
    await tester.tap(find.byKey(const Key('section-menu-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('section-$section')));
    await tester.pumpAndSettle();
  }

  testWidgets('home screen smoke test', (tester) async {
    await pumpApp(tester);

    expect(find.text('Workout'), findsOneWidget);
    expect(find.text("Today's plan"), findsOneWidget);
    expect(find.text('Weekly goals'), findsOneWidget);
    expect(find.text('Tap + to add your first exercise'), findsOneWidget);
    expect(find.text('Completed workouts'), findsOneWidget);
    expect(find.text('0 / 3'), findsOneWidget);
  });

  testWidgets('app bar menu switches sections', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('section-menu-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('section-statistics')));
    await tester.pumpAndSettle();

    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('No exercises saved yet'), findsOneWidget);

    await tester.tap(find.byKey(const Key('section-menu-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('section-settings')));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Local SQLite database'), findsOneWidget);

    await tester.tap(find.byKey(const Key('section-menu-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('section-home')));
    await tester.pumpAndSettle();

    expect(find.text('Workout'), findsOneWidget);
    expect(find.text("Today's plan"), findsOneWidget);
  });

  testWidgets('app bar keeps workout actions on home only', (tester) async {
    await pumpApp(tester);

    expect(find.byKey(const Key('history-button')), findsOneWidget);
    expect(find.byKey(const Key('finish-workout-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('section-menu-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('section-settings')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('history-button')), findsNothing);
    expect(find.byKey(const Key('finish-workout-button')), findsNothing);
  });

  testWidgets('exercise library picker adds an exercise without typing', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('add-exercise-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('exercise-search-field')), findsOneWidget);
    expect(find.byKey(const Key('muscle-chip-Chest')), findsOneWidget);
    expect(find.byKey(const Key('muscle-header-Chest')), findsOneWidget);

    await tester.tap(find.byKey(const Key('muscle-chip-Back')));
    await tester.pumpAndSettle();

    final pullUp = find.byKey(const Key('library-exercise-Pull-Up'));
    expect(pullUp, findsOneWidget);
    expect(
      find.byKey(const Key('library-exercise-Barbell Bench Press')),
      findsNothing,
    );

    await tester.ensureVisible(pullUp);
    await tester.pumpAndSettle();
    await tester.tap(pullUp);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(TodayPlanCard),
        matching: find.text('Pull-Up'),
      ),
      findsOneWidget,
    );
    expect(find.text('1 set'), findsOneWidget);
  });

  testWidgets('custom exercise can still be created', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('add-exercise-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('exercise-search-field')),
      'My Lift',
    );
    await tester.pumpAndSettle();
    final createButton = find.byKey(const Key('create-custom-exercise'));
    await tester.ensureVisible(createButton);
    await tester.pumpAndSettle();
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(TodayPlanCard),
        matching: find.text('My Lift'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('custom exercises can be deleted from the picker', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('add-exercise-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('exercise-search-field')),
      'My Lift',
    );
    await tester.pumpAndSettle();
    final createButton = find.byKey(const Key('create-custom-exercise'));
    await tester.ensureVisible(createButton);
    await tester.pumpAndSettle();
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-exercise-button')));
    await tester.pumpAndSettle();

    final deleteButton = find.byKey(const Key('delete-custom-My Lift'));
    expect(deleteButton, findsOneWidget);
    await tester.ensureVisible(deleteButton);
    await tester.pumpAndSettle();
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.text('Delete exercise?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(deleteButton, findsNothing);
    expect(find.byKey(const Key('muscle-header-Custom')), findsNothing);
  });

  testWidgets('weekly goals can be edited in settings', (tester) async {
    await pumpApp(tester);

    await openSection(tester, 'settings');
    await tester.enterText(find.byKey(const Key('workouts-goal-field')), '5');

    final saveButton = find.byKey(const Key('save-goals-button'));
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Weekly goals saved'), findsOneWidget);

    await openSection(tester, 'home');

    expect(find.text('0 / 5'), findsOneWidget);
    expect(find.text('Volume'), findsNothing);

    await openSection(tester, 'settings');
    await tester.enterText(find.byKey(const Key('volume-goal-field')), '1200');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    await openSection(tester, 'home');

    expect(find.text('Volume'), findsOneWidget);
    expect(find.textContaining('1200 kg'), findsOneWidget);

    await openSection(tester, 'statistics');

    expect(find.text('Weekly goals'), findsOneWidget);
    expect(find.text('0 / 5'), findsOneWidget);
    expect(find.textContaining('/ 1200 kg'), findsOneWidget);
  });

  testWidgets('routine can be built with planned sets and started', (
    tester,
  ) async {
    final database = await pumpApp(tester);
    final routineRepository = DriftRoutineRepository(database);

    await tester.tap(find.byKey(const Key('routines-button')));
    await tester.pumpAndSettle();
    expect(find.text('No routines yet'), findsOneWidget);

    await tester.tap(find.byKey(const Key('new-routine-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('routine-name-field')),
      'Push day',
    );

    await tester.tap(find.byKey(const Key('add-routine-exercise-button')));
    await tester.pumpAndSettle();

    final bench = find.byKey(const Key('library-exercise-Barbell Bench Press'));
    await tester.ensureVisible(bench);
    await tester.pumpAndSettle();
    await tester.tap(bench);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('routine-exercise-Barbell Bench Press')),
      findsOneWidget,
    );

    final plus = find.byKey(const Key('set-count-plus-Barbell Bench Press'));
    await tester.ensureVisible(plus);
    await tester.pumpAndSettle();
    await tester.tap(plus);
    await tester.pumpAndSettle();

    expect(find.text('2 sets'), findsOneWidget);

    final save = find.byKey(const Key('save-routine-button'));
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.text('Workout'), findsOneWidget);

    await tester.tap(find.byKey(const Key('start-routine-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('start-routine-Push day')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(TodayPlanCard),
        matching: find.text('Barbell Bench Press'),
      ),
      findsOneWidget,
    );
    expect(find.text('2 sets'), findsOneWidget);
    expect(find.byKey(const Key('save-as-routine-button')), findsNothing);
    expect(find.text('From routine: Push day'), findsOneWidget);

    final addSet = find.text('Add set');
    await tester.ensureVisible(addSet);
    await tester.pumpAndSettle();
    await tester.tap(addSet);
    await tester.pumpAndSettle();

    expect(find.text('3 sets'), findsOneWidget);

    final savedRoutine = (await routineRepository.loadRoutines()).single;
    expect(savedRoutine.name, 'Push day');
    expect(savedRoutine.exercises.single.name, 'Barbell Bench Press');
    expect(savedRoutine.exercises.single.setCount, 2);

    await tester.tap(find.byKey(const Key('finish-workout-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('save-as-routine-button')), findsOneWidget);
    expect(find.byKey(const Key('routine-source-label')), findsNothing);
  });

  testWidgets('current workout can be saved as a routine', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('add-exercise-button')));
    await tester.pumpAndSettle();
    final pullUp = find.byKey(const Key('library-exercise-Pull-Up'));
    await tester.ensureVisible(pullUp);
    await tester.pumpAndSettle();
    await tester.tap(pullUp);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('save-as-routine-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('routine-name-field')),
      'My routine',
    );
    await tester.tap(find.byKey(const Key('save-as-routine-confirm')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Saved as routine'), findsOneWidget);

    await tester.tap(find.byKey(const Key('start-routine-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('start-routine-My routine')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(TodayPlanCard),
        matching: find.text('Pull-Up'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('completed workout populates statistics overview', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('add-exercise-button')));
    await tester.pumpAndSettle();
    final pullUp = find.byKey(const Key('library-exercise-Pull-Up'));
    await tester.ensureVisible(pullUp);
    await tester.pumpAndSettle();
    await tester.tap(pullUp);
    await tester.pumpAndSettle();

    final weight = find.byKey(const Key('weight-0-0'));
    await tester.ensureVisible(weight);
    await tester.pumpAndSettle();
    await tester.enterText(weight, '50');
    final reps = find.byKey(const Key('reps-0-0'));
    await tester.ensureVisible(reps);
    await tester.pumpAndSettle();
    await tester.enterText(reps, '5');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('finish-workout-button')));
    await tester.pumpAndSettle();

    await openSection(tester, 'statistics');

    expect(find.text('Workouts per week'), findsOneWidget);
    expect(find.text('Volume per week (kg)'), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('activity-workouts-value-11')))
          .data,
      '1',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const Key('activity-volume-value-11')))
          .data,
      '250',
    );

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.textContaining('Best set: 50 kg × 5'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pr-metric-5-0')));
    await tester.pumpAndSettle();

    expect(find.textContaining('kg 5RM (estimated)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('log-pr-button-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('manual-pr-reps-5')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('manual-pr-weight-field')),
      '120',
    );
    await tester.tap(find.byKey(const Key('manual-pr-save')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Manual 5RM: 120 kg'), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete-pr-button-0')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Manual 5RM: 120 kg'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('50 kg × 5 @ RIR 0'), findsOneWidget);
    expect(find.textContaining("Today's workout"), findsOneWidget);
  });
}
