import 'package:flutter/material.dart';
import 'package:virtus_app/models/routine.dart';
import 'package:virtus_app/repositories/routine_repository.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';
import 'package:virtus_app/widgets/add_exercise_bottom_sheet.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({
    super.key,
    required this.repository,
    required this.statisticsRepository,
    this.onTemplatesChanged,
  });

  final RoutineRepository repository;
  final StatisticsRepository statisticsRepository;
  final VoidCallback? onTemplatesChanged;

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final TextEditingController _nameController = TextEditingController();
  late Future<List<Routine>> _routines;

  bool _editorOpen = false;
  Routine? _editing;
  List<RoutineExercise> _exercises = const [];

  @override
  void initState() {
    super.initState();
    _routines = widget.repository.loadRoutines();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _newRoutine() {
    _nameController.clear();
    setState(() {
      _editorOpen = true;
      _editing = null;
      _exercises = <RoutineExercise>[];
    });
  }

  void _editRoutine(Routine routine) {
    _nameController.text = routine.name;
    setState(() {
      _editorOpen = true;
      _editing = routine;
      _exercises = routine.exercises
          .map(
            (e) => RoutineExercise(
              id: e.id,
              name: e.name,
              setCount: e.setCount,
              templateId: e.templateId,
            ),
          )
          .toList();
    });
  }

  Future<void> _addExercise() async {
    final name = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => AddExerciseBottomSheet(
        repository: widget.statisticsRepository,
        onTemplatesChanged: widget.onTemplatesChanged,
      ),
    );
    if (name == null || name.trim().isEmpty || !mounted) return;

    setState(() {
      _exercises = [..._exercises, RoutineExercise(name: name.trim())];
    });
  }

  void _changeSetCount(int index, int delta) {
    setState(() {
      final exercise = _exercises[index];
      exercise.setCount = (exercise.setCount + delta).clamp(1, 20);
    });
  }

  void _removeExercise(int index) {
    setState(() {
      final updated = [..._exercises]..removeAt(index);
      _exercises = updated;
    });
  }

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      final updated = [..._exercises];
      final exercise = updated.removeAt(oldIndex);
      updated.insert(newIndex, exercise);
      _exercises = updated;
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _exercises.isEmpty) {
      _showMessage('Add a name and at least one exercise');
      return;
    }

    await widget.repository.saveRoutine(
      Routine(
        id: _editing?.id,
        name: name,
        createdAt: _editing?.createdAt,
        exercises: _exercises
            .map(
              (e) => RoutineExercise(
                id: e.id,
                name: e.name,
                setCount: e.setCount,
                templateId: e.templateId,
              ),
            )
            .toList(),
      ),
    );
    if (!mounted) return;

    setState(() {
      _editorOpen = false;
      _editing = null;
      _exercises = const [];
      _routines = widget.repository.loadRoutines();
    });
    _showMessage('Routine saved');
    Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final routine = _editing;
    if (routine == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete routine?'),
        content: Text('Remove "${routine.name}" from your routines?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await widget.repository.deleteRoutine(routine.id);
    if (!mounted) return;

    setState(() {
      _editorOpen = false;
      _editing = null;
      _exercises = const [];
      _routines = widget.repository.loadRoutines();
    });
    _showMessage('Routine deleted');
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          !_editorOpen
              ? 'Routines'
              : _editing == null
              ? 'New routine'
              : 'Edit routine',
        ),
        actions: [
          if (_editorOpen)
            IconButton(
              key: const Key('save-routine-button'),
              icon: const Icon(Icons.save),
              tooltip: 'Save routine',
              onPressed: _save,
            ),
          if (_editorOpen && _editing != null)
            IconButton(
              key: const Key('delete-routine-button'),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete routine',
              onPressed: _delete,
            ),
        ],
      ),
      floatingActionButton: _editorOpen
          ? null
          : FloatingActionButton(
              key: const Key('new-routine-button'),
              onPressed: _newRoutine,
              child: const Icon(Icons.add),
            ),
      body: _editorOpen ? _buildEditor() : _buildList(),
    );
  }

  Widget _buildList() {
    return FutureBuilder<List<Routine>>(
      future: _routines,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final routines = snapshot.data ?? const <Routine>[];
        if (routines.isEmpty) {
          return const Center(child: Text('No routines yet'));
        }

        return ListView(
          children: [
            for (final routine in routines)
              ListTile(
                key: ValueKey('routine-${routine.name}'),
                leading: const Icon(Icons.playlist_play),
                title: Text(routine.name),
                subtitle: Text('${routine.exercises.length} exercises'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editRoutine(routine),
                ),
                onTap: () => _editRoutine(routine),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEditor() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          key: const Key('routine-name-field'),
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Routine name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Text('Exercises', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _exercises.length,
          onReorderItem: _reorderExercises,
          itemBuilder: (context, index) {
            final exercise = _exercises[index];
            return Card(
              key: ValueKey('routine-exercise-${exercise.name}'),
              child: ListTile(
                title: Text(exercise.name),
                subtitle: Row(
                  children: [
                    IconButton(
                      key: ValueKey('set-count-minus-${exercise.name}'),
                      icon: const Icon(Icons.remove),
                      onPressed: () => _changeSetCount(index, -1),
                    ),
                    Text(
                      '${exercise.setCount} sets',
                      key: ValueKey('set-count-${exercise.name}'),
                    ),
                    IconButton(
                      key: ValueKey('set-count-plus-${exercise.name}'),
                      icon: const Icon(Icons.add),
                      onPressed: () => _changeSetCount(index, 1),
                    ),
                  ],
                ),
                trailing: IconButton(
                  key: ValueKey('remove-routine-exercise-${exercise.name}'),
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removeExercise(index),
                ),
              ),
            );
          },
        ),
        ListTile(
          key: const Key('add-routine-exercise-button'),
          leading: const Icon(Icons.add),
          title: const Text('Add exercise'),
          onTap: _addExercise,
        ),
      ],
    );
  }
}
