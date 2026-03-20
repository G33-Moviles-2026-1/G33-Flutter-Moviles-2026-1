import '../entities/free_rooms_for_day.dart';
import '../entities/manual_class.dart';
import '../entities/schedule_class.dart';
import '../entities/weekly_schedule.dart';

abstract class ScheduleRepository {
  Future<void> uploadIcsSchedule({
    required String userEmail,
    required String filePath,
  });

  Future<void> uploadManualSchedule({
    required String userEmail,
    required List<ManualClass> classes,
  });

  Future<WeeklySchedule> getWeeklySchedule({
    required String userEmail,
    required DateTime date,
  });

  Future<List<ScheduleClass>> getScheduleClasses({
    required String userEmail,
  });

  Future<FreeRoomsForDay> getFreeRoomsForDay({
    required String userEmail,
    required DateTime date,
  });

  Future<void> deleteFullSchedule({
    required String userEmail,
  });

  Future<void> deleteScheduleClass({
    required String userEmail,
    required String classId,
  });

  Future<void> deleteScheduleOccurrence({
    required String userEmail,
    required String classId,
    required DateTime date,
  });
}