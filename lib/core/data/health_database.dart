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
          version: 2,
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 2) {
              await db.execute('DROP TABLE IF EXISTS app_settings');
            }
          },
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
