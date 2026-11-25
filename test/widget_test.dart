import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtus_app/data/database.dart';
import 'package:virtus_app/main.dart';
import 'package:virtus_app/repositories/drift_workout_repository.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';

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
}
