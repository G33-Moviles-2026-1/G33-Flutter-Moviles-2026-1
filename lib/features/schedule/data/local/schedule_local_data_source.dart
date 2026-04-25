import 'dart:convert';

import 'package:andespace/core/local/app_database.dart';
import 'package:andespace/features/schedule/domain/entities/manual_class.dart';
import 'package:andespace/features/schedule/domain/entities/schedule_class.dart';
import 'package:andespace/features/schedule/domain/entities/schedule_occurrence.dart';
import 'package:andespace/features/schedule/domain/entities/weekly_schedule.dart';
import 'package:drift/drift.dart';

abstract class ScheduleLocalDataSource {
  Future<void> replaceClasses({required List<ScheduleClass> classes});

  Future<void> saveManualClasses({required List<ManualClass> classes});

  Future<List<ScheduleClass>> getClasses();

  Future<WeeklySchedule> getWeeklySchedule({required DateTime date});

  Future<void> clearSchedule();

  Future<void> deleteClass({required String classId});

  Future<void> deleteOccurrence({
    required String classId,
    required DateTime date,
  });

  Future<void> cacheRecommendedRooms({
    required DateTime date,
    required Map<String, dynamic> raw,
  });

  Future<(Map<String, dynamic>?, DateTime?)> getCachedRecommendedRooms({
    required DateTime date,
  });
}

class ScheduleLocalDataSourceImpl implements ScheduleLocalDataSource {
  final AppDatabase db;

  const ScheduleLocalDataSourceImpl({required this.db});

  @override
  Future<void> replaceClasses({required List<ScheduleClass> classes}) {
    final normalized = _deduplicateClasses(classes);

    return db.replaceScheduleClasses(
      normalized.map((e) => _classToCompanion(e)).toList(),
    );
  }

  @override
  Future<void> saveManualClasses({required List<ManualClass> classes}) {
    final now = DateTime.now();

    final rows = classes.map((e) {
      final normalizedWeekdays = _normalizeWeekdays(e.weekdays);

      final classId = _buildStableClassId(
        title: e.title,
        locationText: e.locationText,
        roomId: e.roomId,
        startDate: e.startDate,
        endDate: e.endDate,
        startTime: e.startTime,
        endTime: e.endTime,
        weekdays: normalizedWeekdays,
      );

      return ScheduleClassesTableCompanion(
        classId: Value(classId),
        title: Value(e.title.trim()),
        locationText: Value(_cleanNullable(e.locationText ?? e.roomId)),
        roomId: Value(_cleanNullable(e.roomId ?? e.locationText)),
        startDate: Value(_dateOnly(e.startDate)),
        endDate: Value(_dateOnly(e.endDate)),
        startTime: Value(e.startTime.trim()),
        endTime: Value(e.endTime.trim()),
        weekdaysJson: Value(jsonEncode(normalizedWeekdays)),
        syncState: const Value('pending_sync'),
        updatedAt: Value(now),
      );
    }).toList();

    return db.upsertScheduleClasses(rows);
  }

  @override
  Future<List<ScheduleClass>> getClasses() async {
    final rows = await db.getScheduleClasses();

    final classes = rows.map(_rowToClass).toList();

    return _deduplicateClasses(classes);
  }

  @override
  Future<WeeklySchedule> getWeeklySchedule({required DateTime date}) async {
    final classes = await getClasses();
    final weekStart = _startOfWeek(date);
    final weekEnd = weekStart.add(const Duration(days: 6));

    final uniqueOccurrences = <String, ScheduleOccurrence>{};

    for (final scheduleClass in classes) {
      final normalizedWeekdays = _normalizeWeekdays(scheduleClass.weekdays);

      for (var i = 0; i < 7; i++) {
        final day = weekStart.add(Duration(days: i));
        final weekday = _weekdayName(day);

        final isInsideDateRange =
            !day.isBefore(_dateOnly(scheduleClass.startDate)) &&
            !day.isAfter(_dateOnly(scheduleClass.endDate));

        final matchesWeekday = normalizedWeekdays.contains(weekday);

        if (!isInsideDateRange || !matchesWeekday) {
          continue;
        }

        final occurrence = ScheduleOccurrence(
          classId: scheduleClass.classId,
          title: scheduleClass.title,
          locationText: scheduleClass.locationText,
          roomId: scheduleClass.roomId,
          date: day,
          weekday: weekday,
          startTime: scheduleClass.startTime,
          endTime: scheduleClass.endTime,
        );

        uniqueOccurrences[_occurrenceKey(occurrence)] = occurrence;
      }
    }

    final occurrences = uniqueOccurrences.values.toList()
      ..sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        return a.startTime.compareTo(b.startTime);
      });

    return WeeklySchedule(
      weekStart: weekStart,
      weekEnd: weekEnd,
      occurrences: occurrences,
    );
  }

  @override
  Future<void> clearSchedule() {
    return db.clearSchedule();
  }

  @override
  Future<void> deleteClass({required String classId}) {
    return db.deleteScheduleClass(classId);
  }

  @override
  Future<void> deleteOccurrence({
    required String classId,
    required DateTime date,
  }) {
    return db.deleteScheduleClass(classId);
  }

  ScheduleClassesTableCompanion _classToCompanion(ScheduleClass entity) {
    final normalizedWeekdays = _normalizeWeekdays(entity.weekdays);

    return ScheduleClassesTableCompanion(
      classId: Value(entity.classId.trim()),
      title: Value(entity.title?.trim()),
      locationText: Value(_cleanNullable(entity.locationText)),
      roomId: Value(_cleanNullable(entity.roomId)),
      startDate: Value(_dateOnly(entity.startDate)),
      endDate: Value(_dateOnly(entity.endDate)),
      startTime: Value(entity.startTime.trim()),
      endTime: Value(entity.endTime.trim()),
      weekdaysJson: Value(jsonEncode(normalizedWeekdays)),
      syncState: const Value('synced'),
      updatedAt: Value(DateTime.now()),
    );
  }

  ScheduleClass _rowToClass(ScheduleClassesTableData row) {
    return ScheduleClass(
      classId: row.classId,
      title: row.title,
      locationText: row.locationText,
      roomId: row.roomId,
      startDate: _dateOnly(row.startDate),
      endDate: _dateOnly(row.endDate),
      startTime: row.startTime,
      endTime: row.endTime,
      weekdays: _decodeWeekdays(row.weekdaysJson),
    );
  }

  List<ScheduleClass> _deduplicateClasses(List<ScheduleClass> classes) {
    final unique = <String, ScheduleClass>{};

    for (final scheduleClass in classes) {
      final key = _classContentKey(scheduleClass);
      unique[key] = scheduleClass;
    }

    return unique.values.toList()..sort((a, b) {
      final startDateCompare = a.startDate.compareTo(b.startDate);
      if (startDateCompare != 0) return startDateCompare;
      return a.startTime.compareTo(b.startTime);
    });
  }

  String _classContentKey(ScheduleClass entity) {
    return _buildStableClassId(
      title: entity.title ?? '',
      locationText: entity.locationText,
      roomId: entity.roomId,
      startDate: entity.startDate,
      endDate: entity.endDate,
      startTime: entity.startTime,
      endTime: entity.endTime,
      weekdays: entity.weekdays,
    );
  }

  String _buildStableClassId({
    required String title,
    required String? locationText,
    required String? roomId,
    required DateTime startDate,
    required DateTime endDate,
    required String startTime,
    required String endTime,
    required List<String> weekdays,
  }) {
    final raw = [
      'manual',
      title.trim().toLowerCase(),
      locationText?.trim().toLowerCase() ?? '',
      roomId?.trim().toLowerCase() ?? '',
      _formatDateKey(startDate),
      _formatDateKey(endDate),
      startTime.trim(),
      endTime.trim(),
      _normalizeWeekdays(weekdays).join('-').toLowerCase(),
    ].join('_');

    return raw.replaceAll(RegExp(r'[^a-z0-9_:-]'), '_');
  }

  String _occurrenceKey(ScheduleOccurrence occurrence) {
    return [
      _formatDateKey(occurrence.date),
      occurrence.title?.trim().toLowerCase() ?? '',
      occurrence.locationText?.trim().toLowerCase() ?? '',
      occurrence.roomId?.trim().toLowerCase() ?? '',
      occurrence.startTime.trim(),
      occurrence.endTime.trim(),
    ].join('|');
  }

  List<String> _decodeWeekdays(String weekdaysJson) {
    try {
      final decoded = jsonDecode(weekdaysJson);

      if (decoded is! List) {
        return const [];
      }

      return _normalizeWeekdays(decoded.map((e) => e.toString()).toList());
    } catch (_) {
      return const [];
    }
  }

  List<String> _normalizeWeekdays(List<String> weekdays) {
    final normalized = weekdays
        .map(_normalizeWeekday)
        .where((weekday) => weekday != null)
        .cast<String>()
        .toSet()
        .toList();

    normalized.sort((a, b) => _weekdayIndex(a).compareTo(_weekdayIndex(b)));

    return normalized;
  }

  String? _normalizeWeekday(String value) {
    final clean = value.trim().toLowerCase();

    switch (clean) {
      case 'monday':
      case 'mon':
      case 'lunes':
      case 'lu':
        return 'Monday';
      case 'tuesday':
      case 'tue':
      case 'martes':
      case 'ma':
        return 'Tuesday';
      case 'wednesday':
      case 'wed':
      case 'miercoles':
      case 'miércoles':
      case 'mi':
        return 'Wednesday';
      case 'thursday':
      case 'thu':
      case 'jueves':
      case 'ju':
        return 'Thursday';
      case 'friday':
      case 'fri':
      case 'viernes':
      case 'vi':
        return 'Friday';
      case 'saturday':
      case 'sat':
      case 'sabado':
      case 'sábado':
      case 'sa':
        return 'Saturday';
      case 'sunday':
      case 'sun':
      case 'domingo':
      case 'do':
        return 'Sunday';
      default:
        return null;
    }
  }

  int _weekdayIndex(String weekday) {
    switch (weekday) {
      case 'Monday':
        return DateTime.monday;
      case 'Tuesday':
        return DateTime.tuesday;
      case 'Wednesday':
        return DateTime.wednesday;
      case 'Thursday':
        return DateTime.thursday;
      case 'Friday':
        return DateTime.friday;
      case 'Saturday':
        return DateTime.saturday;
      case 'Sunday':
        return DateTime.sunday;
      default:
        return 99;
    }
  }

  DateTime _startOfWeek(DateTime date) {
    final clean = _dateOnly(date);
    return clean.subtract(Duration(days: clean.weekday - DateTime.monday));
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatDateKey(DateTime date) {
    final clean = _dateOnly(date);
    final month = clean.month.toString().padLeft(2, '0');
    final day = clean.day.toString().padLeft(2, '0');
    return '${clean.year}-$month-$day';
  }

  String _weekdayName(DateTime date) {
    const names = {
      DateTime.monday: 'Monday',
      DateTime.tuesday: 'Tuesday',
      DateTime.wednesday: 'Wednesday',
      DateTime.thursday: 'Thursday',
      DateTime.friday: 'Friday',
      DateTime.saturday: 'Saturday',
      DateTime.sunday: 'Sunday',
    };

    return names[date.weekday]!;
  }

  String? _cleanNullable(String? value) {
    final clean = value?.trim();

    if (clean == null || clean.isEmpty) {
      return null;
    }

    return clean;
  }

  @override
  Future<void> cacheRecommendedRooms({
    required DateTime date,
    required Map<String, dynamic> raw,
  }) {
    return db.upsertRecommendedRooms(
      key: _formatDateKey(date),
      json: jsonEncode(raw),
    );
  }

  @override
  Future<(Map<String, dynamic>?, DateTime?)> getCachedRecommendedRooms({
    required DateTime date,
  }) async {
    final cached = await db.getRecommendedRooms(_formatDateKey(date));

    if (cached == null) {
      return (null, null);
    }

    final decoded = jsonDecode(cached.dataJson);

    if (decoded is! Map<String, dynamic>) {
      return (null, null);
    }

    return (decoded, cached.updatedAt);
  }
}
