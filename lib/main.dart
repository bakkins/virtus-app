import 'package:flutter/widget_previews.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

@Preview(name: 'Sākuma ekrāna priekšskats')
Widget mainAppPreview() {
  return const MainApp();
} // Vajadzigs prieks preview

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
