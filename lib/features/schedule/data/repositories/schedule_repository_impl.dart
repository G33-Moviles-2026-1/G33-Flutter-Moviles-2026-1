import 'package:andespace/features/rooms/domain/entities/room_search.dart';

import '../../domain/entities/free_rooms_for_day.dart';
import '../../domain/entities/manual_class.dart';
import '../../domain/entities/schedule_class.dart';
import '../../domain/entities/schedule_occurrence.dart';
import '../../domain/entities/weekly_schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_data_source.dart';
import '../models/manual_class_model.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;

  const ScheduleRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<void> uploadIcsSchedule({
    required String userEmail,
    required String filePath,
  }) async {
    await remoteDataSource.uploadIcsSchedule(
      userEmail: userEmail,
      filePath: filePath,
    );
  }

  @override
  Future<void> uploadManualSchedule({
    required String userEmail,
    required List<ManualClass> classes,
  }) async {
    final models = classes
        .map(
          (e) => ManualClassModel(
            title: e.title,
            locationText: e.locationText,
            roomId: e.roomId,
            startDate: e.startDate,
            endDate: e.endDate,
            startTime: e.startTime,
            endTime: e.endTime,
            weekdays: e.weekdays,
          ),
        )
        .toList();

    await remoteDataSource.uploadManualSchedule(
      userEmail: userEmail,
      classes: models,
    );
  }

  @override
  Future<WeeklySchedule> getWeeklySchedule({
    required String userEmail,
    required DateTime date,
  }) async {
    final model = await remoteDataSource.getWeeklySchedule(
      userEmail: userEmail,
      date: date,
    );

    return WeeklySchedule(
      weekStart: model.weekStart,
      weekEnd: model.weekEnd,
      occurrences: model.occurrences
          .map(
            (e) => ScheduleOccurrence(
              classId: e.classId,
              title: e.title,
              locationText: e.locationText,
              roomId: (e.roomId != null && e.roomId!.trim().isNotEmpty)
                  ? e.roomId
                  : e.locationText,
              date: e.date,
              weekday: e.weekday,
              startTime: e.startTime,
              endTime: e.endTime,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<List<ScheduleClass>> getScheduleClasses({
    required String userEmail,
  }) async {
    final models = await remoteDataSource.getScheduleClasses(
      userEmail: userEmail,
    );

    return models
        .map(
          (e) => ScheduleClass(
            classId: e.classId,
            title: e.title,
            locationText: e.locationText,
            roomId: (e.roomId != null && e.roomId!.trim().isNotEmpty)
              ? e.roomId
              : e.locationText,
            startDate: e.startDate,
            endDate: e.endDate,
            startTime: e.startTime,
            endTime: e.endTime,
            weekdays: e.weekdays,
          ),
        )
        .toList();
  }

  @override
  Future<FreeRoomsForDay> getFreeRoomsForDay({
    required String userEmail,
    required DateTime date,
  }) async {
    final model = await remoteDataSource.getFreeRoomsForDay(
      userEmail: userEmail,
      date: date,
    );

    return FreeRoomsForDay(
      date: model.date,
      weekday: model.weekday,
      freeSlots: model.freeSlots
          .map(
            (e) => FreeSlot(
              startTime: e.startTime,
              endTime: e.endTime,
            ),
          )
          .toList(),
      slotsWithRooms: model.slotsWithRooms
          .map(
            (slot) => SlotWithRooms(
              slotStart: slot.slotStart,
              slotEnd: slot.slotEnd,
              availableRooms: slot.availableRooms
                  .map(
                    (room) => RoomInSlot(
                      roomId: room.roomId,
                      buildingName: room.buildingName,
                      capacity: room.capacity,
                      reliability: room.reliability,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }

  @override
  Future<void> deleteFullSchedule({
    required String userEmail,
  }) async {
    await remoteDataSource.deleteFullSchedule(
      userEmail: userEmail,
    );
  }

  @override
  Future<void> deleteScheduleClass({
    required String userEmail,
    required String classId,
  }) async {
    await remoteDataSource.deleteScheduleClass(
      userEmail: userEmail,
      classId: classId,
    );
  }

  @override
  Future<void> deleteScheduleOccurrence({
    required String userEmail,
    required String classId,
    required DateTime date,
  }) async {
    await remoteDataSource.deleteScheduleOccurrence(
      userEmail: userEmail,
      classId: classId,
      date: date,
    );
  }

  @override
  Future<List<RoomSearchItem>> getRecommendedRoomsForDay({
    required String userEmail,
    required DateTime date,
  }) async {
    final raw = await remoteDataSource.getRecommendedRoomsForDay(
      date: date,
    );

    final slots = raw['slots'] as List<dynamic>? ?? [];
    final items = <RoomSearchItem>[];

    for (final slot in slots) {
      final slotMap = Map<String, dynamic>.from(slot as Map);
      final slotStart = slotMap['slot_start'] as String? ?? '';
      final slotEnd = slotMap['slot_end'] as String? ?? '';

      final recommendedRooms =
          slotMap['recommended_rooms'] as List<dynamic>? ?? [];

      for (final room in recommendedRooms) {
        final roomMap = Map<String, dynamic>.from(room as Map);

        final roomId = roomMap['room_id'] as String? ?? '';
        final buildingName = roomMap['building_name'] as String?;
        final capacity = roomMap['capacity'] as int? ?? 0;
        final reliability =
            (roomMap['reliability'] as num?)?.toDouble() ?? 0.0;

        final score = (roomMap['score'] as num?)?.toDouble();
        final fromPrevious =
            (roomMap['from_previous_seconds'] as num?)?.toDouble();
        final toNext =
            (roomMap['to_next_seconds'] as num?)?.toDouble();

        final parts = roomId.split(' ');
        final buildingCode = parts.isNotEmpty ? parts.first : '';
        final roomNumber = parts.length > 1 ? parts.sublist(1).join(' ') : '';

        items.add(
          RoomSearchItem(
            roomId: roomId,
            buildingCode: buildingCode,
            buildingName: buildingName,
            roomNumber: roomNumber,
            capacity: capacity,
            reliability: reliability,
            utilities: [
              if (score != null) 'score ${score.toStringAsFixed(2)}',
              if (fromPrevious != null) 'prev ${(fromPrevious / 60).round()} min',
              if (toNext != null) 'next ${(toNext / 60).round()} min',
            ],
            distanceSeconds: toNext ?? fromPrevious,
            matchingWindows: [
              MatchingWindow(start: slotStart, end: slotEnd),
            ],
            weeklyAvailability: const [],
          ),
        );
      }
    }

    return items;
  }
}