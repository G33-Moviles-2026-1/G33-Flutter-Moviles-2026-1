import 'package:andespace/features/rooms/domain/entities/room_search.dart';

import '../../domain/entities/free_rooms_for_day.dart';
import '../../domain/entities/manual_class.dart';
import '../../domain/entities/schedule_class.dart';
import '../../domain/entities/weekly_schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../mappers/free_rooms_mapper.dart';
import '../mappers/manual_class_mapper.dart';
import '../mappers/recommended_rooms_mapper.dart';
import '../mappers/schedule_class_mapper.dart';
import '../mappers/weekly_schedule_mapper.dart';
import '../remote/schedule_remote_data_source.dart';

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
    final models = ManualClassMapper.toModelList(classes);

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

    return WeeklyScheduleMapper.toEntity(model);
  }

  @override
  Future<List<ScheduleClass>> getScheduleClasses({
    required String userEmail,
  }) async {
    final models = await remoteDataSource.getScheduleClasses(
      userEmail: userEmail,
    );

    return ScheduleClassMapper.toEntityList(models);
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

    return FreeRoomsForDayMapper.toEntity(model);
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

    return RecommendedRoomsMapper.fromRaw(raw);
  }
}