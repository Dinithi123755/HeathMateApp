import 'package:flutter/foundation.dart';
import '../../settings/domain/app_settings.dart';
import '../data/health_repository.dart';
import '../domain/health_record.dart';

class HealthViewModel extends ChangeNotifier {
  HealthViewModel(this.repository, {DateTime Function()? now})
    : now = now ?? DateTime.now;
  final HealthRepository repository;
  final DateTime Function() now;
  List<HealthRecord> _records = [];
  List<HealthRecord> get records => List.unmodifiable(_records);
  AppSettings settings = const AppSettings();
  bool loading = true;
  bool ready = false;
  bool busy = false;
  String? error;
  DateTime? filterStart;
  DateTime? filterEnd;
  DateTime get today => calendarDay(now());
  bool get hasDemo => _records.any((r) => r.isDemo);
  List<HealthRecord> get filtered => _records
      .where(
        (row) =>
            (filterStart == null || !row.date.isBefore(filterStart!)) &&
            (filterEnd == null || !row.date.isAfter(filterEnd!)),
      )
      .toList();
  List<HealthRecord> onDate(DateTime day) =>
      _records.where((row) => dateKey(row.date) == dateKey(day)).toList();
  DailyTotals totalsOn(DateTime day) => DailyTotals.fromRecords(onDate(day));
  DailyTotals get todayTotals => totalsOn(today);
  List<DateTime> days(int count) => List.generate(
    count,
    (index) => DateTime(today.year, today.month, today.day - count + index + 1),
  );
  DailyTotals periodTotals(int count) => DailyTotals.fromRecords(
    _records.where(
      (r) => !r.date.isBefore(days(count).first) && !r.date.isAfter(today),
    ),
  );
  int activeDays(int count) =>
      days(count).where((day) => onDate(day).isNotEmpty).length;
  int get streak {
    var day = today;
    if (onDate(day).isEmpty) day = DateTime(day.year, day.month, day.day - 1);
    var count = 0;
    while (onDate(day).isNotEmpty) {
      count++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return count;
  }

  void filter(DateTime? start, DateTime? end) {
    filterStart = start == null ? null : calendarDay(start);
    filterEnd = end == null ? null : calendarDay(end);
    notifyListeners();
  }

  Future<void> initialize() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      _records = await repository.records();
      settings = await repository.settings();
      ready = true;
    } catch (_) {
      error = 'Could not open your local data. Please try again.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> _change(Future<void> Function() action) async {
    if (busy) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      _records = await repository.records();
      settings = await repository.settings();
      return true;
    } on FormatException catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error =
          'Could not complete the change. Check your records before trying again.';
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> save(HealthRecord row) => _change(() async {
    RecordRules.validate(row, now());
    await repository.save(row);
  });
  Future<bool> delete(HealthRecord row) =>
      _change(() => repository.delete(row.id!));
  Future<bool> updateSettings(AppSettings value) =>
      _change(() => repository.saveSettings(value));
  Future<bool> loadDemo() => _change(() => repository.loadDemo(today));
  Future<bool> removeDemo() => _change(repository.removeDemo);
  void refreshDate() => notifyListeners();
}
