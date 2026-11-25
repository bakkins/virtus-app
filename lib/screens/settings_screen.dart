import 'package:flutter/material.dart';
import 'package:virtus_app/models/weekly_goals.dart';
import 'package:virtus_app/repositories/settings_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.repository,
    required this.onGoalsSaved,
  });

  final SettingsRepository repository;
  final VoidCallback onGoalsSaved;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _workoutsController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.repository.loadGoals().then((goals) {
      if (!mounted) return;
      setState(() {
        _workoutsController.text = goals.workouts.toString();
        _volumeController.text = goals.volume?.toString() ?? '';
      });
    });
  }

  @override
  void dispose() {
    _workoutsController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final workouts = int.tryParse(_workoutsController.text.trim());
    final volumeText = _volumeController.text.trim();
    final volume = volumeText.isEmpty ? null : double.tryParse(volumeText);

    if (workouts == null ||
        workouts <= 0 ||
        (volumeText.isNotEmpty && (volume == null || volume <= 0))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter positive goal values')),
      );
      return;
    }

    await widget.repository.saveGoals(
      WeeklyGoals(workouts: workouts, volume: volume),
    );
    if (!mounted) return;

    widget.onGoalsSaved();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Weekly goals saved')));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Weekly goals',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('workouts-goal-field'),
          controller: _workoutsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Completed workouts per week',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('volume-goal-field'),
          controller: _volumeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Volume per week (kg, optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          key: const Key('save-goals-button'),
          icon: const Icon(Icons.save),
          label: const Text('Save goals'),
          onPressed: _save,
        ),
        const SizedBox(height: 16),
        const Text(
          'App',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const ListTile(
          leading: Icon(Icons.storage),
          title: Text('Storage'),
          subtitle: Text('Local SQLite database'),
        ),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Version'),
          subtitle: Text('0.1.0'),
        ),
        const SizedBox(height: 16),
        const Text(
          'Coming soon',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const ListTile(
          leading: Icon(Icons.person_outline),
          title: Text('Account'),
          subtitle: Text('Not available offline'),
          enabled: false,
        ),
        const ListTile(
          leading: Icon(Icons.cloud_off),
          title: Text('Sync'),
          subtitle: Text('Not available offline'),
          enabled: false,
        ),
        const ListTile(
          leading: Icon(Icons.people_outline),
          title: Text('Friends'),
          subtitle: Text('Not available offline'),
          enabled: false,
        ),
      ],
    );
  }
}
