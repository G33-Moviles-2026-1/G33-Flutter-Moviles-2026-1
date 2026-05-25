import 'package:andespace/features/rooms/domain/entities/room_search.dart';

import '../entities/free_rooms_for_day.dart';
import '../entities/friends_free_slot.dart';
import '../entities/google_calendar_auth_session.dart';
import '../entities/google_calendar_source.dart';
import '../entities/manual_class.dart';
import '../entities/schedule_class.dart';
import '../entities/weekly_schedule.dart';

abstract class ScheduleRepository {
  Future<void> uploadIcsSchedule({required String filePath});

  Future<GoogleCalendarAuthSession> startGoogleCalendarConnection();

  Future<List<GoogleCalendarSource>> getGoogleCalendars({
    required String state,
  });

  Future<void> uploadGoogleCalendarSchedule({
    required String state,
    required List<String> calendarIds,
  });

  Future<void> uploadManualSchedule({required List<ManualClass> classes});

  Future<WeeklySchedule> getWeeklySchedule({required DateTime date});

  Future<List<ScheduleClass>> getScheduleClasses();

  Future<FreeRoomsForDay> getFreeRoomsForDay({required DateTime date});

  Future<FriendsFreeSlots> getFriendsFreeSlots({
    required List<String> friendEmails,
    required DateTime date,
  });

  Future<void> deleteFullSchedule();

  Future<void> clearLocalSchedule();

  Future<void> deleteScheduleClass({required String classId});

  Future<void> deleteScheduleOccurrencesFromDate({
    required String classId,
    required DateTime date,
  });

  Future<void> refreshScheduleClassesFromRemote();

  Future<void> deleteScheduleOccurrence({
    required String classId,
    required DateTime date,
  });

  Future<(List<RoomSearchItem>, DateTime?)> getRecommendedRoomsForDay({
    required DateTime date,
  });
}
