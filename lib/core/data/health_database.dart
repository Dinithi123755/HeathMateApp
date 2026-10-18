import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class HealthDatabase {
  HealthDatabase({DatabaseFactory? factory, this.path})
    : _factory = factory ?? databaseFactory;
  final DatabaseFactory _factory;
  final String? path;
  Future<Database>? _opening;
  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    try {
      final location =
          path ?? p.join(await _factory.getDatabasesPath(), 'healthmate.db');
      return await _factory.openDatabase(
        location,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''CREATE TABLE health_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            steps INTEGER NOT NULL CHECK(steps BETWEEN 0 AND 200000),
            calories INTEGER NOT NULL CHECK(calories BETWEEN 0 AND 30000),
            water INTEGER NOT NULL CHECK(water BETWEEN 0 AND 20000),
            is_demo INTEGER NOT NULL DEFAULT 0 CHECK(is_demo IN (0,1)),
            CHECK(steps + calories + water > 0)
          )''');
            await db.execute(
              'CREATE INDEX idx_health_records_date ON health_records(date)',
            );
            await db.execute('''CREATE TABLE app_settings (
            id INTEGER PRIMARY KEY CHECK(id = 1),
            steps_goal INTEGER NOT NULL CHECK(steps_goal BETWEEN 1 AND 200000),
            calories_goal INTEGER NOT NULL CHECK(calories_goal BETWEEN 1 AND 30000),
            water_goal INTEGER NOT NULL CHECK(water_goal BETWEEN 1 AND 20000),
            dark_mode INTEGER NOT NULL CHECK(dark_mode IN (0,1))
          )''');
            await db.insert('app_settings', {
              'id': 1,
              'steps_goal': 8000,
              'calories_goal': 400,
              'water_goal': 2000,
              'dark_mode': 0,
            });
          },
        ),
      );
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<void> close() async {
    final opening = _opening;
    _opening = null;
    if (opening != null) await (await opening).close();
  }
}
