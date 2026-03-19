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
}