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
          Text(
            exercise.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < sets.length; i++)
            _setRow(colorScheme: colorScheme, setIndex: i, set: sets[i]),
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
        FilteringTextInputFormatter.allow(RegExp(decimal ? r'[0-9.]' : r'[0-9]')),
      ],
      decoration: InputDecoration(
        labelText: label,
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
  }) {
    return Padding(
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
              initial: _weightText(set.weight),
              label: 'kg',
              decimal: true,
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null) _onChanged(setIndex, weight: parsed);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _numberField(
              initial: set.reps.toString(),
              label: 'reps',
              decimal: false,
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null) _onChanged(setIndex, reps: parsed);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _numberField(
              initial: set.rir.toString(),
              label: 'rir',
              decimal: false,
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null) _onChanged(setIndex, rir: parsed);
              },
            ),
          ),
        ],
      ),
    );
  }
}