import 'package:andespace/features/rooms/domain/entities/room_search.dart';

import '../entities/free_rooms_for_day.dart';
import '../entities/manual_class.dart';
import '../entities/schedule_class.dart';
import '../entities/weekly_schedule.dart';

abstract class ScheduleRepository {
  Future<void> uploadIcsSchedule({
    required String filePath,
  });

  Future<void> uploadManualSchedule({
    required List<ManualClass> classes,
  });

  Future<WeeklySchedule> getWeeklySchedule({
    required DateTime date,
  });

  Future<List<ScheduleClass>> getScheduleClasses();

  Future<FreeRoomsForDay> getFreeRoomsForDay({
    required DateTime date,
  });

  Future<void> deleteFullSchedule();

  Future<void> deleteScheduleClass({
    required String classId,
  });

  Future<void> deleteScheduleOccurrence({
    required String classId,
    required DateTime date,
  });

  Future<List<RoomSearchItem>> getRecommendedRoomsForDay({
    required DateTime date,
  });
}