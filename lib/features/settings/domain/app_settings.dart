class AppSettings {
  const AppSettings({
    this.stepsGoal = 8000,
    this.caloriesGoal = 400,
    this.waterGoal = 2000,
    this.darkMode = false,
  });
  final int stepsGoal;
  final int caloriesGoal;
  final int waterGoal;
  final bool darkMode;
  Map<String, Object?> toMap() => {
    'id': 1,
    'steps_goal': stepsGoal,
    'calories_goal': caloriesGoal,
    'water_goal': waterGoal,
    'dark_mode': darkMode ? 1 : 0,
  };
  factory AppSettings.fromMap(Map<String, Object?> row) => AppSettings(
    stepsGoal: row['steps_goal'] as int,
    caloriesGoal: row['calories_goal'] as int,
    waterGoal: row['water_goal'] as int,
    darkMode: row['dark_mode'] == 1,
  );
  AppSettings copyWith({
    int? stepsGoal,
    int? caloriesGoal,
    int? waterGoal,
    bool? darkMode,
  }) => AppSettings(
    stepsGoal: stepsGoal ?? this.stepsGoal,
    caloriesGoal: caloriesGoal ?? this.caloriesGoal,
    waterGoal: waterGoal ?? this.waterGoal,
    darkMode: darkMode ?? this.darkMode,
  );
}
