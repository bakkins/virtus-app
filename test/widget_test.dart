import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtus_app/data/database.dart';
import 'package:virtus_app/main.dart';
import 'package:virtus_app/repositories/drift_workout_repository.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';
import 'package:virtus_app/widgets/today_plan_card.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      MainApp(
        repository: DriftWorkoutRepository(database),
        statisticsRepository: DriftStatisticsRepository(database),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('home screen smoke test', (tester) async {
    await pumpApp(tester);

    expect(find.text('Workout'), findsOneWidget);
    expect(find.text("Today's plan"), findsOneWidget);
    expect(find.text('Weekly goals'), findsOneWidget);
    expect(find.text('Tap + to add your first exercise'), findsOneWidget);
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
}
