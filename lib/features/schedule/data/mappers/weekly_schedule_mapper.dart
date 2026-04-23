import '../../domain/entities/schedule_occurrence.dart';
import '../../domain/entities/weekly_schedule.dart';
import '../models/weekly_schedule_dto.dart';

class WeeklyScheduleMapper {
  const WeeklyScheduleMapper._();

  static WeeklySchedule toEntity(WeeklyScheduleModel model) {
    return WeeklySchedule(
      weekStart: model.weekStart,
      weekEnd: model.weekEnd,
      occurrences: model.occurrences.map(_toOccurrenceEntity).toList(),
    );
  }

  static ScheduleOccurrence _toOccurrenceEntity(
    ScheduleOccurrenceModel model,
  ) {
    return ScheduleOccurrence(
      classId: model.classId,
      title: model.title,
      locationText: model.locationText,
      roomId: _normalizeRoomId(
        model.roomId,
        fallback: model.locationText,
      ),
      date: model.date,
      weekday: model.weekday,
      startTime: model.startTime,
      endTime: model.endTime,
    );
  }

  static String? _normalizeRoomId(String? roomId, {required String? fallback}) {
    if (roomId != null && roomId.trim().isNotEmpty) {
      return roomId;
    }
    return fallback;
  }
}