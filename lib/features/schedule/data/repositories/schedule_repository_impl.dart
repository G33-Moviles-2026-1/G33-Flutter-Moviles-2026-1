import 'package:andespace/core/connectivity/connectivity_queue_service.dart';
import 'package:andespace/core/connectivity/pending_action.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/schedule/data/local/schedule_local_data_source.dart';
import 'package:dio/dio.dart';

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
  final ScheduleLocalDataSource localDataSource;
  final ConnectivityQueueService connectivityQueueService;

  const ScheduleRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityQueueService,
  });

  bool _isConnectivityError(Object e) {
    return e is DioException && e.response == null;
  }

  @override
  Future<void> uploadIcsSchedule({
    required String filePath,
  }) async {
    await remoteDataSource.uploadIcsSchedule(
      filePath: filePath,
    );
  }

  @override
  Future<void> uploadManualSchedule({
    required List<ManualClass> classes,
  }) async {
    final models = ManualClassMapper.toModelList(classes);

    try {
      await remoteDataSource.uploadManualSchedule(
        classes: models,
      );

      final remoteClasses = await remoteDataSource.getScheduleClasses();

      await localDataSource.replaceClasses(
        classes: ScheduleClassMapper.toEntityList(remoteClasses),
      );
    } catch (e) {
      if (!_isConnectivityError(e)) rethrow;

      await localDataSource.saveManualClasses(
        classes: classes,
      );

      connectivityQueueService.enqueue(
        _UploadManualSchedulePendingAction(
          remoteDataSource: remoteDataSource,
          classes: models,
        ),
      );
    }
  }

  @override
  Future<WeeklySchedule> getWeeklySchedule({
    required DateTime date,
  }) async {
    try {
      final model = await remoteDataSource.getWeeklySchedule(
        date: date,
      );

      final remoteClasses = await remoteDataSource.getScheduleClasses();

      await localDataSource.replaceClasses(
        classes: ScheduleClassMapper.toEntityList(remoteClasses),
      );

      return WeeklyScheduleMapper.toEntity(model);
    } catch (e) {
      if (!_isConnectivityError(e)) rethrow;

      return localDataSource.getWeeklySchedule(
        date: date,
      );
    }
  }

  @override
  Future<List<ScheduleClass>> getScheduleClasses() async {
    try {
      final models = await remoteDataSource.getScheduleClasses();

      final classes = ScheduleClassMapper.toEntityList(models);

      await localDataSource.replaceClasses(
        classes: classes
      );

      return classes;
    } catch (e) {
      if (!_isConnectivityError(e)) rethrow;

      return localDataSource.getClasses();
    }
  }

  @override
  Future<FreeRoomsForDay> getFreeRoomsForDay({
    required DateTime date,
  }) async {
    final model = await remoteDataSource.getFreeRoomsForDay(
      date: date,
    );

    return FreeRoomsForDayMapper.toEntity(model);
  }

  @override
  Future<void> deleteFullSchedule() async {
    await localDataSource.clearSchedule();

    try {
      await remoteDataSource.deleteFullSchedule();
    } catch (e) {
      if (!_isConnectivityError(e)) rethrow;

      connectivityQueueService.enqueue(
        _DeleteFullSchedulePendingAction(
          remoteDataSource: remoteDataSource,
        ),
      );
    }
  }

  @override
  Future<void> deleteScheduleClass({
    required String classId,
  }) async {
    await remoteDataSource.deleteScheduleClass(
      classId: classId,
    );
  }

  @override
  Future<void> deleteScheduleOccurrence({
    required String classId,
    required DateTime date,
  }) async {
    await remoteDataSource.deleteScheduleOccurrence(
      classId: classId,
      date: date,
    );
  }

  @override
  Future<List<RoomSearchItem>> getRecommendedRoomsForDay({
    required DateTime date,
  }) async {
    final raw = await remoteDataSource.getRecommendedRoomsForDay(date: date);

    return RecommendedRoomsMapper.fromRaw(raw);
  }
}

class _UploadManualSchedulePendingAction implements PendingAction {
  final ScheduleRemoteDataSource remoteDataSource;
  final List<dynamic> classes;

  const _UploadManualSchedulePendingAction({
    required this.remoteDataSource,
    required this.classes,
  });

  @override
  String get successMessage => 'Horario sincronizado correctamente.';

  @override
  String get failureMessage => 'No pudimos sincronizar el horario.';

  @override
  Future<void> execute() {
    return remoteDataSource.uploadManualSchedule(
      classes: classes.cast(),
    );
  }
}

class _DeleteFullSchedulePendingAction implements PendingAction {
  final ScheduleRemoteDataSource remoteDataSource;

  const _DeleteFullSchedulePendingAction({
    required this.remoteDataSource,
  });

  @override
  String get successMessage => 'Horario eliminado correctamente.';

  @override
  String get failureMessage =>
      'No pudimos sincronizar la eliminación del horario.';

  @override
  Future<void> execute() {
    return remoteDataSource.deleteFullSchedule();
  }
}
