import 'dart:convert';

import 'package:andespace/core/local/app_database.dart';
import 'package:andespace/features/schedule/domain/entities/manual_class.dart';
import 'package:andespace/features/schedule/domain/entities/schedule_class.dart';
import 'package:andespace/features/schedule/domain/entities/schedule_occurrence.dart';
import 'package:andespace/features/schedule/domain/entities/schedule_weekday.dart';
import 'package:andespace/features/schedule/domain/entities/weekly_schedule.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/friends_free_slot.dart';

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

  Future<void> deleteOccurrencesFromDate({
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

  Future<void> cacheFriendWeeklySchedule({
    required String friendEmail,
    required DateTime date,
    required WeeklySchedule schedule,
  });

  Future<(WeeklySchedule?, DateTime?)> getCachedFriendWeeklySchedule({
    required String friendEmail,
    required DateTime date,
  });

  Future<void> cacheFriendsFreeSlots({
    required List<String> friendEmails,
    required DateTime date,
    required FriendsFreeSlots freeSlots,
  });

  Future<(FriendsFreeSlots?, DateTime?)> getCachedFriendsFreeSlots({
    required List<String> friendEmails,
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

    return db.replaceScheduleClasses(rows);
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
  }) async {
    final classes = await getClasses();
    final target = _findClass(classes, classId);

    if (target == null) return;

    final replacement = _removeSingleOccurrence(target, date);

    await replaceClasses(
      classes: [...classes.where((e) => e.classId != classId), ...replacement],
    );
  }

  @override
  Future<void> deleteOccurrencesFromDate({
    required String classId,
    required DateTime date,
  }) async {
    final classes = await getClasses();
    final target = _findClass(classes, classId);

    if (target == null) return;

    final cutoff = _dateOnly(date);
    if (cutoff.isAfter(target.endDate)) return;

    final previousDay = cutoff.subtract(const Duration(days: 1));
    final replacement = previousDay.isBefore(target.startDate)
        ? <ScheduleClass>[]
        : [
            _copyClass(
              target,
              classId: '${target.classId}_until_${_formatDateKey(previousDay)}',
              endDate: previousDay,
            ),
          ];

    await replaceClasses(
      classes: [...classes.where((e) => e.classId != classId), ...replacement],
    );
  }

  ScheduleClass? _findClass(List<ScheduleClass> classes, String classId) {
    for (final scheduleClass in classes) {
      if (scheduleClass.classId == classId) {
        return scheduleClass;
      }
    }

    return null;
  }

  List<ScheduleClass> _removeSingleOccurrence(
    ScheduleClass scheduleClass,
    DateTime occurrenceDate,
  ) {
    final cleanDate = _dateOnly(occurrenceDate);
    final occurrenceWeekday = _weekdayName(cleanDate);

    final isInsideRange =
        !cleanDate.isBefore(scheduleClass.startDate) &&
        !cleanDate.isAfter(scheduleClass.endDate);
    final matchesWeekday = _normalizeWeekdays(
      scheduleClass.weekdays,
    ).contains(occurrenceWeekday);

    if (!isInsideRange || !matchesWeekday) {
      return [scheduleClass];
    }

    final previousDay = cleanDate.subtract(const Duration(days: 1));
    final nextDay = cleanDate.add(const Duration(days: 1));
    final replacement = <ScheduleClass>[];

    if (!previousDay.isBefore(scheduleClass.startDate)) {
      replacement.add(
        _copyClass(
          scheduleClass,
          classId:
              '${scheduleClass.classId}_before_${_formatDateKey(cleanDate)}',
          endDate: previousDay,
        ),
      );
    }

    if (!nextDay.isAfter(scheduleClass.endDate)) {
      replacement.add(
        _copyClass(
          scheduleClass,
          classId:
              '${scheduleClass.classId}_after_${_formatDateKey(cleanDate)}',
          startDate: nextDay,
        ),
      );
    }

    return replacement;
  }

  ScheduleClass _copyClass(
    ScheduleClass scheduleClass, {
    required String classId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ScheduleClass(
      classId: classId,
      title: scheduleClass.title,
      locationText: scheduleClass.locationText,
      roomId: scheduleClass.roomId,
      startDate: startDate ?? scheduleClass.startDate,
      endDate: endDate ?? scheduleClass.endDate,
      startTime: scheduleClass.startTime,
      endTime: scheduleClass.endTime,
      weekdays: scheduleClass.weekdays,
    );
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
      case ScheduleWeekday.monday:
        return ScheduleWeekday.monday;
      case ScheduleWeekday.tuesday:
        return ScheduleWeekday.tuesday;
      case ScheduleWeekday.wednesday:
        return ScheduleWeekday.wednesday;
      case ScheduleWeekday.thursday:
        return ScheduleWeekday.thursday;
      case ScheduleWeekday.friday:
        return ScheduleWeekday.friday;
      case ScheduleWeekday.saturday:
        return ScheduleWeekday.saturday;
      case ScheduleWeekday.sunday:
        return ScheduleWeekday.sunday;
      default:
        return null;
    }
  }

  int _weekdayIndex(String weekday) {
    return ScheduleWeekday.index(weekday);
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
    return ScheduleWeekday.fromDateTimeWeekday(date.weekday)!;
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

  @override
  Future<void> cacheFriendWeeklySchedule({
    required String friendEmail,
    required DateTime date,
    required WeeklySchedule schedule,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'cached_at': DateTime.now().toIso8601String(),
      'schedule': _weeklyScheduleToJson(schedule),
    };

    await prefs.setString(
      _friendScheduleCacheKey(friendEmail: friendEmail, date: date),
      jsonEncode(payload),
    );
  }

  @override
  Future<(WeeklySchedule?, DateTime?)> getCachedFriendWeeklySchedule({
    required String friendEmail,
    required DateTime date,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(
      _friendScheduleCacheKey(friendEmail: friendEmail, date: date),
    );
    if (raw == null) return (null, null);

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return (null, null);

      final payload = Map<String, dynamic>.from(decoded);
      final schedulePayload = payload['schedule'];
      if (schedulePayload is! Map) return (null, null);

      return (
        _weeklyScheduleFromJson(Map<String, dynamic>.from(schedulePayload)),
        DateTime.tryParse(payload['cached_at']?.toString() ?? ''),
      );
    } catch (_) {
      return (null, null);
    }
  }

  @override
  Future<void> cacheFriendsFreeSlots({
    required List<String> friendEmails,
    required DateTime date,
    required FriendsFreeSlots freeSlots,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'cached_at': DateTime.now().toIso8601String(),
      'free_slots': _friendsFreeSlotsToJson(freeSlots),
    };

    await prefs.setString(
      _friendsFreeSlotsCacheKey(friendEmails: friendEmails, date: date),
      jsonEncode(payload),
    );
  }

  @override
  Future<(FriendsFreeSlots?, DateTime?)> getCachedFriendsFreeSlots({
    required List<String> friendEmails,
    required DateTime date,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(
      _friendsFreeSlotsCacheKey(friendEmails: friendEmails, date: date),
    );
    if (raw == null) return (null, null);

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return (null, null);

      final payload = Map<String, dynamic>.from(decoded);
      final freeSlotsPayload = payload['free_slots'];
      if (freeSlotsPayload is! Map) return (null, null);

      return (
        _friendsFreeSlotsFromJson(Map<String, dynamic>.from(freeSlotsPayload)),
        DateTime.tryParse(payload['cached_at']?.toString() ?? ''),
      );
    } catch (_) {
      return (null, null);
    }
  }
}

String _friendScheduleCacheKey({
  required String friendEmail,
  required DateTime date,
}) {
  final weekStart = _topLevelStartOfWeek(date);
  return [
    'friend_schedule_v1',
    friendEmail.trim().toLowerCase(),
    _topLevelFormatDateKey(weekStart),
  ].join('|');
}

String _friendsFreeSlotsCacheKey({
  required List<String> friendEmails,
  required DateTime date,
}) {
  final normalizedFriends =
      friendEmails
          .map((email) => email.trim().toLowerCase())
          .where((email) => email.isNotEmpty)
          .toList()
        ..sort();

  return [
    'friends_free_slots_v1',
    normalizedFriends.join(','),
    _topLevelFormatDateKey(date),
  ].join('|');
}

Map<String, dynamic> _weeklyScheduleToJson(WeeklySchedule schedule) {
  return {
    'week_start': _topLevelFormatDateKey(schedule.weekStart),
    'week_end': _topLevelFormatDateKey(schedule.weekEnd),
    'occurrences': schedule.occurrences.map((occurrence) {
      return {
        'class_id': occurrence.classId,
        'title': occurrence.title,
        'location_text': occurrence.locationText,
        'room_id': occurrence.roomId,
        'date': _topLevelFormatDateKey(occurrence.date),
        'weekday': occurrence.weekday,
        'start_time': occurrence.startTime,
        'end_time': occurrence.endTime,
      };
    }).toList(),
  };
}

WeeklySchedule _weeklyScheduleFromJson(Map<String, dynamic> json) {
  final occurrences = (json['occurrences'] as List<dynamic>? ?? [])
      .whereType<Map>()
      .map((item) {
        final map = Map<String, dynamic>.from(item);

        return ScheduleOccurrence(
          classId: map['class_id']?.toString() ?? '',
          title: map['title']?.toString(),
          locationText: map['location_text']?.toString(),
          roomId: map['room_id']?.toString(),
          date: DateTime.parse(map['date'] as String),
          weekday: map['weekday']?.toString() ?? '',
          startTime: map['start_time']?.toString() ?? '',
          endTime: map['end_time']?.toString() ?? '',
        );
      })
      .toList();

  return WeeklySchedule(
    weekStart: DateTime.parse(json['week_start'] as String),
    weekEnd: DateTime.parse(json['week_end'] as String),
    occurrences: occurrences,
  );
}

Map<String, dynamic> _friendsFreeSlotsToJson(FriendsFreeSlots freeSlots) {
  return {
    'total_friends': freeSlots.totalFriends,
    'slots': freeSlots.slots.map((slot) {
      return {
        'date': slot.date == null ? null : _topLevelFormatDateKey(slot.date!),
        'weekday': slot.weekday,
        'start_time': slot.startTime,
        'end_time': slot.endTime,
        'free_count': slot.freeCount,
        'available_friends': slot.availableFriends,
      };
    }).toList(),
  };
}

FriendsFreeSlots _friendsFreeSlotsFromJson(Map<String, dynamic> json) {
  return FriendsFreeSlots(
    totalFriends: (json['total_friends'] as num?)?.toInt() ?? 0,
    slots: (json['slots'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((item) {
          final map = Map<String, dynamic>.from(item);
          final rawDate = map['date']?.toString();

          return FriendFreeSlot(
            date: rawDate == null || rawDate.isEmpty
                ? null
                : DateTime.tryParse(rawDate),
            weekday: map['weekday']?.toString(),
            startTime: map['start_time']?.toString() ?? '',
            endTime: map['end_time']?.toString() ?? '',
            freeCount: (map['free_count'] as num?)?.toInt() ?? 0,
            availableFriends: (map['available_friends'] as List<dynamic>? ?? [])
                .map((item) => item.toString())
                .where((item) => item.trim().isNotEmpty)
                .toList(),
          );
        })
        .where((slot) => slot.startTime.isNotEmpty && slot.endTime.isNotEmpty)
        .toList(),
  );
}

DateTime _topLevelStartOfWeek(DateTime date) {
  final clean = DateTime(date.year, date.month, date.day);
  return clean.subtract(Duration(days: clean.weekday - DateTime.monday));
}

String _topLevelFormatDateKey(DateTime date) {
  final clean = DateTime(date.year, date.month, date.day);
  final month = clean.month.toString().padLeft(2, '0');
  final day = clean.day.toString().padLeft(2, '0');
  return '${clean.year}-$month-$day';
}
