import 'package:flutter/material.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';

class AddExerciseBottomSheet extends StatefulWidget {
  const AddExerciseBottomSheet({super.key, required this.repository});

  final StatisticsRepository repository;

  @override
  State<AddExerciseBottomSheet> createState() => _AddExerciseBottomSheetState();
}

class _AddExerciseBottomSheetState extends State<AddExerciseBottomSheet> {
  final TextEditingController _textController = TextEditingController();
  late final Future<List<SavedExercise>> _saved;

  @override
  void initState() {
    super.initState();
    _saved = widget.repository.savedExercises();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit([String? value]) {
    final name = (value ?? _textController.text).trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final typed = _textController.text.trim();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Exercise name',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: FutureBuilder<List<SavedExercise>>(
                future: _saved,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = snapshot.data ?? const <SavedExercise>[];
                  if (items.isEmpty) {
                    return const Center(child: Text('No saved exercises yet'));
                  }

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final exercise = items[i];
                      return ListTile(
                        title: Text(exercise.name),
                        subtitle: exercise.category == null
                            ? null
                            : Text(exercise.category!),
                        onTap: () => _submit(exercise.name),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: typed.isEmpty ? null : () => _submit(),
                child: Text(
                  typed.isEmpty ? 'Type a name to create' : 'Create "$typed"',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
