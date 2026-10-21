import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virtus_app/models/exercise.dart';
import 'package:virtus_app/models/workout_set.dart';
import 'package:virtus_app/state/workout_controller.dart';

class ExerciseWidget extends StatelessWidget {
  final Exercise exercise;
  final WorkoutController controller;
  final int index;

  const ExerciseWidget({
    super.key,
    required this.exercise,
    required this.controller,
    required this.index,
  });

  String _weightText(double value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toString();

  void _onChanged(int setIndex, {double? weight, int? reps, int? rir}) {
    controller.updateSet(index, setIndex, weight: weight, reps: reps, rir: rir);
  }

  Future<bool> _confirmDelete(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete exercise?'),
      content: Text('Delete "${exercise.name}" and all its sets?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sets = exercise.sets;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_handle,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: colorScheme.error,
                onPressed: () async {
                  if (await _confirmDelete(context))
                  {controller.removeExercise(index);}
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < sets.length; i++)
            _setRow(colorScheme: colorScheme, setIndex: i, set: sets[i], context: context),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => controller.addSet(index),
              icon: const Icon(Icons.add),
              label: const Text('Add set'),
            ),
          ),
        ],
      ),
    );
  }

  TextFormField _numberField({
    required String initial,
    required String label,
    required bool decimal,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: initial,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(decimal ? r'[0-9.]' : r'[0-9]'),
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: initial.isEmpty ? '-' : null,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  Widget _setRow({
    required ColorScheme colorScheme,
    required int setIndex,
    required WorkoutSet set,
    required BuildContext context
  }) {
    return Padding(
      key: ObjectKey(set),
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '${setIndex + 1}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _numberField(
              initial: set.weight == 0 ? '' : _weightText(set.weight),
              label: 'kg',
              decimal: true,
              onChanged: (value) {
                _onChanged(setIndex, weight: double.tryParse(value) ?? 0);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _numberField(
              initial: set.reps == 0 ? '' : set.reps.toString(),
              label: 'reps',
              decimal: false,
              onChanged: (value) {
                _onChanged(setIndex, reps: int.tryParse(value) ?? 0);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _numberField(
              initial: set.rir == 0 ? '' : set.rir.toString(),
              label: 'rir',
              decimal: false,
              onChanged: (value) {
                _onChanged(setIndex, rir: int.tryParse(value) ?? 0);
              },
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: colorScheme.error,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            onPressed: () async {
              if (exercise.sets.length == 1) {
                if (await _confirmDelete(context)) controller.removeExercise(index);
              } else {
                controller.removeSet(index, setIndex);
              }
            },
          ),
        ],
      ),
    );
  }
}
