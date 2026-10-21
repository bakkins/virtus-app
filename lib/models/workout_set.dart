import 'package:uuid/uuid.dart';

class WorkoutSet {
  final String id;
  double weight;
  int reps;
  int rir;

  WorkoutSet({
    String? id,
    required this.weight,
    required this.reps,
    required this.rir,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'weight': weight,
    'reps': reps,
    'rir': rir,
  };

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
    id: json['id'] as String?,
    weight: (json['weight'] as num).toDouble(),
    reps: json['reps'] as int,
    rir: json['rir'] as int,
  );
}
