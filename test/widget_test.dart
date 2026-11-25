import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtus_app/data/database.dart';
import 'package:virtus_app/main.dart';
import 'package:virtus_app/repositories/drift_workout_repository.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';

void main() {
  testWidgets('workout screen smoke test', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      MainApp(
        repository: DriftWorkoutRepository(db),
        statisticsRepository: DriftStatisticsRepository(db),
      ),
    );

    expect(find.text('Workout'), findsOneWidget);
    expect(find.text('Tap + to add your first exercise'), findsOneWidget);
  });
}
