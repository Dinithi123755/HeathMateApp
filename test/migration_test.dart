import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:healthmate/core/data/health_database.dart';
import 'package:healthmate/features/records/data/health_repository.dart';

void main() {
  sqfliteFfiInit();
  test('TC13 removing preferences preserves existing health records', () async {
    final folder = await Directory.systemTemp.createTemp(
      'healthmate_migration_',
    );
    final path = '${folder.path}/old.db';
    final old = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE health_records (id INTEGER PRIMARY KEY, date TEXT, steps INTEGER, calories INTEGER, water INTEGER, is_demo INTEGER)',
          );
          await db.execute(
            'CREATE TABLE app_settings (id INTEGER PRIMARY KEY)',
          );
          await db.insert('health_records', {
            'id': 7,
            'date': '2026-10-18',
            'steps': 1500,
            'calories': 120,
            'water': 500,
            'is_demo': 0,
          });
        },
      ),
    );
    await old.close();
    final upgraded = HealthDatabase(factory: databaseFactoryFfi, path: path);
    try {
      final rows = await SqliteHealthRepository(upgraded).records();
      expect(rows.single.id, 7);
      expect(rows.single.steps, 1500);
      expect(rows.single.water, 500);
      final db = await upgraded.database;
      expect(await db.getVersion(), 2);
      expect(
        await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE name = 'app_settings'",
        ),
        isEmpty,
      );
    } finally {
      await upgraded.close();
      await folder.delete(recursive: true);
    }
  });
}
