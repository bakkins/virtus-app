import 'package:flutter/material.dart';
import 'package:virtus_app/data/exercise_library.dart';
import 'package:virtus_app/repositories/statistics_repository.dart';

class AddExerciseBottomSheet extends StatefulWidget {
  const AddExerciseBottomSheet({super.key, required this.repository});

  final StatisticsRepository repository;

  @override
  State<AddExerciseBottomSheet> createState() => _AddExerciseBottomSheetState();
}

class _AddExerciseBottomSheetState extends State<AddExerciseBottomSheet> {
  static const _customGroup = 'Custom';

  final TextEditingController _searchController = TextEditingController();
  String _selectedGroup = 'All';
  late final Future<List<SavedExercise>> _saved;

  @override
  void initState() {
    super.initState();
    _saved = widget.repository.savedExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _groups => ['All', ...muscleGroups, _customGroup];

  List<_ExerciseOption> _options(List<SavedExercise> saved) {
    final query = _searchController.text.trim().toLowerCase();
    final catalogNames = exerciseLibrary
        .map((entry) => entry.name.toLowerCase())
        .toSet();

    bool matches(String name) =>
        query.isEmpty || name.toLowerCase().contains(query);

    bool inGroup(String group) =>
        _selectedGroup == 'All' || _selectedGroup == group;

    return [
      for (final entry in exerciseLibrary)
        if (inGroup(entry.muscleGroup) && matches(entry.name))
          _ExerciseOption(entry.name, entry.muscleGroup, entry.equipment),
      for (final item in saved)
        if (!catalogNames.contains(item.name.toLowerCase()) &&
            inGroup(item.muscleGroup) &&
            matches(item.name))
          _ExerciseOption(item.name, item.muscleGroup, null),
    ];
  }

  Future<void> _select(String name, String muscleGroup) async {
    await widget.repository.ensureTemplate(
      name: name,
      muscleGroup: muscleGroup,
    );
    if (!mounted) return;
    Navigator.of(context).pop(name);
  }

  List<Widget> _listChildren(List<_ExerciseOption> options) {
    final children = <Widget>[];

    for (final group in [...muscleGroups, _customGroup]) {
      final groupOptions = options
          .where((option) => option.muscleGroup == group)
          .toList();
      if (groupOptions.isEmpty) continue;

      children.add(_GroupHeader(group: group));
      children.addAll(
        groupOptions.map(
          (option) => ListTile(
            key: ValueKey('library-exercise-${option.name}'),
            dense: true,
            title: Text(option.name),
            subtitle: option.detail == null ? null : Text(option.detail!),
            trailing: const Icon(Icons.add, size: 18),
            onTap: () => _select(option.name, option.muscleGroup),
          ),
        ),
      );
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    final typed = _searchController.text.trim();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('exercise-search-field'),
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search or create exercise',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final group in _groups)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        key: ValueKey('muscle-chip-$group'),
                        label: Text(group),
                        selected: _selectedGroup == group,
                        onSelected: (_) =>
                            setState(() => _selectedGroup = group),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: FutureBuilder<List<SavedExercise>>(
                future: _saved,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final options = _options(
                    snapshot.data ?? const <SavedExercise>[],
                  );
                  if (options.isEmpty) {
                    return const Center(child: Text('No exercises match'));
                  }

                  return SingleChildScrollView(
                    child: Column(children: _listChildren(options)),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('create-custom-exercise'),
                icon: const Icon(Icons.add),
                label: Text(
                  typed.isEmpty ? 'Create custom exercise' : 'Create "$typed"',
                ),
                onPressed: typed.isEmpty
                    ? null
                    : () => _select(typed, _customGroup),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseOption {
  const _ExerciseOption(this.name, this.muscleGroup, this.detail);

  final String name;
  final String muscleGroup;
  final String? detail;
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});

  final String group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey('muscle-header-$group'),
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Text(
        group.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
