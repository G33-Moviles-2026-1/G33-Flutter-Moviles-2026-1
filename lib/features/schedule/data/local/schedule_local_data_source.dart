import 'dart:convert';

import 'package:andespace/core/local/app_database.dart';
import 'package:andespace/features/schedule/domain/entities/manual_class.dart';
import 'package:andespace/features/schedule/domain/entities/schedule_class.dart';
import 'package:andespace/features/schedule/domain/entities/schedule_occurrence.dart';
import 'package:andespace/features/schedule/domain/entities/weekly_schedule.dart';
import 'package:drift/drift.dart';

abstract class ScheduleLocalDataSource {
  Future<void> replaceClasses({
    required List<ScheduleClass> classes,
  });

  Future<void> saveManualClasses({
    required List<ManualClass> classes,
  });

  Future<List<ScheduleClass>> getClasses();

  Future<WeeklySchedule> getWeeklySchedule({
    required DateTime date,
  });

  Future<void> clearSchedule();
}

class ScheduleLocalDataSourceImpl implements ScheduleLocalDataSource {
  final AppDatabase db;

  const ScheduleLocalDataSourceImpl({
    required this.db,
  });

  @override
  Future<void> replaceClasses({
    required List<ScheduleClass> classes,
  }) {
    return db.replaceScheduleClasses(
      classes.map((e) => _classToCompanion(e)).toList(),
    );
  }

  @override
  Future<void> saveManualClasses({
    required List<ManualClass> classes,
  }) {
    final now = DateTime.now();

    final rows = classes.map((e) {
      final classId =
          'manual_${e.title}_${e.startDate.toIso8601String()}_${e.startTime}'
              .replaceAll(RegExp(r'\s+'), '_');

      return ScheduleClassesTableCompanion(
        classId: Value(classId),
        title: Value(e.title),
        locationText: Value(e.locationText),
        roomId: Value(e.roomId),
        startDate: Value(e.startDate),
        endDate: Value(e.endDate),
        startTime: Value(e.startTime),
        endTime: Value(e.endTime),
        weekdaysJson: Value(jsonEncode(e.weekdays)),
        syncState: const Value('pending_sync'),
        updatedAt: Value(now),
      );
    }).toList();

    return db.upsertScheduleClasses(rows);
  }

  @override
  Future<List<ScheduleClass>> getClasses() async {
    final rows = await db.getScheduleClasses();
    return rows.map(_rowToClass).toList();
  }

  @override
  Future<WeeklySchedule> getWeeklySchedule({
    required DateTime date,
  }) async {
    final classes = await getClasses();
    final weekStart = _startOfWeek(date);
    final weekEnd = weekStart.add(const Duration(days: 6));

    final occurrences = <ScheduleOccurrence>[];

    for (final scheduleClass in classes) {
      for (var i = 0; i < 7; i++) {
        final day = weekStart.add(Duration(days: i));
        final weekday = _weekdayName(day);

        final isInsideDateRange =
            !day.isBefore(_dateOnly(scheduleClass.startDate)) &&
            !day.isAfter(_dateOnly(scheduleClass.endDate));

        final matchesWeekday = scheduleClass.weekdays
            .map((e) => e.toLowerCase())
            .contains(weekday.toLowerCase());

        if (isInsideDateRange && matchesWeekday) {
          occurrences.add(
            ScheduleOccurrence(
              classId: scheduleClass.classId,
              title: scheduleClass.title,
              locationText: scheduleClass.locationText,
              roomId: scheduleClass.roomId,
              date: day,
              weekday: weekday,
              startTime: scheduleClass.startTime,
              endTime: scheduleClass.endTime,
            ),
          );
        }
      }
    }

    occurrences.sort((a, b) {
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

  ScheduleClassesTableCompanion _classToCompanion(
    ScheduleClass entity,
  ) {
    return ScheduleClassesTableCompanion(
      classId: Value(entity.classId),
      title: Value(entity.title),
      locationText: Value(entity.locationText),
      roomId: Value(entity.roomId),
      startDate: Value(entity.startDate),
      endDate: Value(entity.endDate),
      startTime: Value(entity.startTime),
      endTime: Value(entity.endTime),
      weekdaysJson: Value(jsonEncode(entity.weekdays)),
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
      startDate: row.startDate,
      endDate: row.endDate,
      startTime: row.startTime,
      endTime: row.endTime,
      weekdays: (jsonDecode(row.weekdaysJson) as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );
  }

  DateTime _startOfWeek(DateTime date) {
    final clean = _dateOnly(date);
    return clean.subtract(Duration(days: clean.weekday - DateTime.monday));
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
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
}