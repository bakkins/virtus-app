class ExerciseLibraryEntry {
  const ExerciseLibraryEntry(this.name, this.muscleGroup, [this.equipment]);

  final String name;
  final String muscleGroup;
  final String? equipment;
}

const List<String> muscleGroups = <String>[
  'Chest',
  'Back',
  'Shoulders',
  'Biceps',
  'Triceps',
  'Quads',
  'Hamstrings',
  'Glutes',
  'Calves',
  'Core',
  'Full body',
];

const List<ExerciseLibraryEntry> exerciseLibrary = <ExerciseLibraryEntry>[
  ExerciseLibraryEntry('Barbell Bench Press', 'Chest', 'Barbell'),
  ExerciseLibraryEntry('Cable Fly', 'Chest', 'Cable'),
  ExerciseLibraryEntry('Dumbbell Fly', 'Chest', 'Dumbbell'),
  ExerciseLibraryEntry('Incline Dumbbell Press', 'Chest', 'Dumbbell'),
  ExerciseLibraryEntry('Push-Up', 'Chest', 'Bodyweight'),
  ExerciseLibraryEntry('Barbell Row', 'Back', 'Barbell'),
  ExerciseLibraryEntry('Deadlift', 'Back', 'Barbell'),
  ExerciseLibraryEntry('Lat Pulldown', 'Back', 'Cable'),
  ExerciseLibraryEntry('Pull-Up', 'Back', 'Bodyweight'),
  ExerciseLibraryEntry('Seated Cable Row', 'Back', 'Cable'),
  ExerciseLibraryEntry('Face Pull', 'Shoulders', 'Cable'),
  ExerciseLibraryEntry('Lateral Raise', 'Shoulders', 'Dumbbell'),
  ExerciseLibraryEntry('Overhead Press', 'Shoulders', 'Barbell'),
  ExerciseLibraryEntry('Rear Delt Fly', 'Shoulders', 'Dumbbell'),
  ExerciseLibraryEntry('Barbell Curl', 'Biceps', 'Barbell'),
  ExerciseLibraryEntry('Dumbbell Curl', 'Biceps', 'Dumbbell'),
  ExerciseLibraryEntry('Hammer Curl', 'Biceps', 'Dumbbell'),
  ExerciseLibraryEntry('Dips', 'Triceps', 'Bodyweight'),
  ExerciseLibraryEntry('Skull Crusher', 'Triceps', 'Barbell'),
  ExerciseLibraryEntry('Triceps Pushdown', 'Triceps', 'Cable'),
  ExerciseLibraryEntry('Back Squat', 'Quads', 'Barbell'),
  ExerciseLibraryEntry('Front Squat', 'Quads', 'Barbell'),
  ExerciseLibraryEntry('Leg Extension', 'Quads', 'Machine'),
  ExerciseLibraryEntry('Leg Press', 'Quads', 'Machine'),
  ExerciseLibraryEntry('Lying Leg Curl', 'Hamstrings', 'Machine'),
  ExerciseLibraryEntry('Nordic Curl', 'Hamstrings', 'Bodyweight'),
  ExerciseLibraryEntry('Romanian Deadlift', 'Hamstrings', 'Barbell'),
  ExerciseLibraryEntry('Bulgarian Split Squat', 'Glutes', 'Dumbbell'),
  ExerciseLibraryEntry('Cable Kickback', 'Glutes', 'Cable'),
  ExerciseLibraryEntry('Hip Thrust', 'Glutes', 'Barbell'),
  ExerciseLibraryEntry('Seated Calf Raise', 'Calves', 'Machine'),
  ExerciseLibraryEntry('Standing Calf Raise', 'Calves', 'Machine'),
  ExerciseLibraryEntry('Cable Crunch', 'Core', 'Cable'),
  ExerciseLibraryEntry('Hanging Leg Raise', 'Core', 'Bodyweight'),
  ExerciseLibraryEntry('Plank', 'Core', 'Bodyweight'),
  ExerciseLibraryEntry('Russian Twist', 'Core', 'Dumbbell'),
  ExerciseLibraryEntry('Burpee', 'Full body', 'Bodyweight'),
  ExerciseLibraryEntry('Clean and Jerk', 'Full body', 'Barbell'),
  ExerciseLibraryEntry('Kettlebell Swing', 'Full body', 'Kettlebell'),
  ExerciseLibraryEntry('Thruster', 'Full body', 'Barbell'),
];
