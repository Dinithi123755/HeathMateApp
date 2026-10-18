import '../../../core/data/health_database.dart';
import '../../settings/domain/app_settings.dart';
import '../domain/health_record.dart';

abstract class HealthRepository {
  Future<List<HealthRecord>> records();
  Future<void> save(HealthRecord record);
  Future<void> delete(int id);
  Future<AppSettings> settings();
  Future<void> saveSettings(AppSettings settings);
  Future<void> loadDemo(DateTime today);
  Future<void> removeDemo();
}

class SqliteHealthRepository implements HealthRepository {
  SqliteHealthRepository(this.database, {DateTime Function()? now})
    : now = now ?? DateTime.now;
  final HealthDatabase database;
  final DateTime Function() now;
  @override
  Future<List<HealthRecord>> records() async {
    final db = await database.database;
    final rows = await db.query(
      'health_records',
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(HealthRecord.fromMap).toList();
  }

  @override
  Future<void> save(HealthRecord record) async {
    RecordRules.validate(record, now());
    final db = await database.database;
    if (record.id == null) {
      await db.insert('health_records', record.toMap());
    } else {
      final count = await db.update(
        'health_records',
        record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
      if (count != 1) throw StateError('This record no longer exists.');
    }
  }

  @override
  Future<void> delete(int id) async {
    final db = await database.database;
    await db.delete('health_records', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<AppSettings> settings() async {
    final db = await database.database;
    return AppSettings.fromMap(
      (await db.query('app_settings', where: 'id = 1')).single,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final db = await database.database;
    await db.update('app_settings', settings.toMap(), where: 'id = 1');
  }

  @override
  Future<void> loadDemo(DateTime today) async {
    final db = await database.database;
    await db.transaction((txn) async {
      // Replace only marked sample rows; personal records are never overwritten.
      await txn.delete('health_records', where: 'is_demo = 1');
      for (var day = 0; day < 14; day++) {
        await txn.insert(
          'health_records',
          HealthRecord(
            date: DateTime(today.year, today.month, today.day - day),
            steps: 3800 + ((day * 1297 + 4050) % 7200),
            calories: 190 + ((day * 53 + 230) % 410),
            water: 1000 + ((day * 3 + 4) % 7) * 250,
            isDemo: true,
          ).toMap(),
        );
      }
    });
  }

  @override
  Future<void> removeDemo() async {
    final db = await database.database;
    await db.delete('health_records', where: 'is_demo = 1');
  }
}
