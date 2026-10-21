// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:virtus_app/main.dart';
import 'package:virtus_app/repositories/local_workout_repository.dart';

void main() {
testWidgets('workout screen smoke test', (tester) async {
  await tester.pumpWidget(MainApp(repository: LocalWorkoutRepository()));
  expect(find.text('Workout'), findsOneWidget);
  expect(find.text('Tap + to add your first exercise'), findsOneWidget);
});
  }
