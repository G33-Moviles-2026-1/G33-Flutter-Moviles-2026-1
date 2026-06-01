import 'package:andespace/core/connectivity/connectivity_queue_service.dart';
import 'package:andespace/core/connectivity/pending_action.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/schedule/data/local/schedule_local_data_source.dart';
import 'package:andespace/features/schedule/data/models/manual_class_dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/cached_schedule_result.dart';
import '../../domain/entities/free_rooms_for_day.dart';
import '../../domain/entities/friends_free_slot.dart';
import '../../domain/entities/google_calendar_auth_session.dart';
import '../../domain/entities/google_calendar_source.dart';
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
  Future<void> uploadIcsSchedule({required String filePath}) async {
    await remoteDataSource.uploadIcsSchedule(filePath: filePath);

    final remoteClasses = await remoteDataSource.getScheduleClasses();

    await localDataSource.replaceClasses(
      classes: ScheduleClassMapper.toEntityList(remoteClasses),
    );
  }

  @override
  Future<GoogleCalendarAuthSession> startGoogleCalendarConnection() async {
    final model = await remoteDataSource.startGoogleCalendarConnection();
    return model.toEntity();
  }

  @override
  Future<List<GoogleCalendarSource>> getGoogleCalendars({
    required String state,
  }) async {
    final models = await remoteDataSource.getGoogleCalendars(state: state);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> uploadGoogleCalendarSchedule({
    required String state,
    required List<String> calendarIds,
  }) async {
    await remoteDataSource.uploadGoogleCalendarSchedule(
      state: state,
      calendarIds: calendarIds,
    );

    final remoteClasses = await remoteDataSource.getScheduleClasses();

    await localDataSource.replaceClasses(
      classes: ScheduleClassMapper.toEntityList(remoteClasses),
    );
  }

  @override
  Future<void> uploadManualSchedule({
    required List<ManualClass> classes,
  }) async {
    final models = ManualClassMapper.toModelList(classes);
    final normalizedModels = _normalizeManualModelsForBackend(models);

    try {
      await remoteDataSource.uploadManualSchedule(classes: normalizedModels);

      final remoteClasses = await remoteDataSource.getScheduleClasses();

      await localDataSource.replaceClasses(
        classes: ScheduleClassMapper.toEntityList(remoteClasses),
      );
    } catch (e) {
      if (!_isConnectivityError(e)) rethrow;

      await localDataSource.saveManualClasses(classes: classes);

      connectivityQueueService.enqueue(
        _UploadManualSchedulePendingAction(
          remoteDataSource: remoteDataSource,
          classes: normalizedModels,
        ),
      );
    }
  }

  @override
  Future<WeeklySchedule> getWeeklySchedule({required DateTime date}) {
    return localDataSource.getWeeklySchedule(date: date);
  }

  @override
  Future<List<ScheduleClass>> getScheduleClasses() {
    return localDataSource.getClasses();
  }

  @override
  Future<FreeRoomsForDay> getFreeRoomsForDay({required DateTime date}) async {
    final model = await remoteDataSource.getFreeRoomsForDay(date: date);

    return FreeRoomsForDayMapper.toEntity(model);
  }

  @override
  Future<FriendsFreeSlots> getFriendsFreeSlots({
    required List<String> friendEmails,
    required DateTime date,
  }) async {
    final result = await getFriendsFreeSlotsWithCache(
      friendEmails: friendEmails,
      date: date,
    );

    return result.freeSlots;
  }

  @override
  Future<FriendsFreeSlotsResult> getFriendsFreeSlotsWithCache({
    required List<String> friendEmails,
    required DateTime date,
  }) async {
    try {
      final model = await remoteDataSource.getFriendsFreeSlots(
        friendEmails: friendEmails,
        date: date,
      );

      final freeSlots = model.toEntity();

      await localDataSource.cacheFriendsFreeSlots(
        friendEmails: friendEmails,
        date: date,
        freeSlots: freeSlots,
      );

      return FriendsFreeSlotsResult(
        freeSlots: freeSlots,
        isOffline: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      if (!_isConnectivityError(e)) rethrow;

      final cached = await localDataSource.getCachedFriendsFreeSlots(
        friendEmails: friendEmails,
        date: date,
      );
      final freeSlots = cached.$1;

      if (freeSlots == null) rethrow;

      return FriendsFreeSlotsResult(
        freeSlots: freeSlots,
        isOffline: true,
        lastUpdated: cached.$2,
      );
    }
  }

  @override
  Future<FriendWeeklyScheduleResult> getFriendWeeklySchedule({
    required String friendEmail,
    required DateTime date,
  }) async {
    try {
      final model = await remoteDataSource.getFriendWeeklySchedule(
        friendEmail: friendEmail,
        date: date,
      );
      final schedule = WeeklyScheduleMapper.toEntity(model);

      await localDataSource.cacheFriendWeeklySchedule(
        friendEmail: friendEmail,
        date: date,
        schedule: schedule,
      );

      return FriendWeeklyScheduleResult(
        schedule: schedule,
        isOffline: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      if (!_isConnectivityError(e)) rethrow;

      final cached = await localDataSource.getCachedFriendWeeklySchedule(
        friendEmail: friendEmail,
        date: date,
      );
      final schedule = cached.$1;

      if (schedule == null) rethrow;

      return FriendWeeklyScheduleResult(
        schedule: schedule,
        isOffline: true,
        lastUpdated: cached.$2,
      );
    }
  }

  @override
  Future<void> deleteFullSchedule() async {
    await localDataSource.clearSchedule();

    try {
      await remoteDataSource.deleteFullSchedule();
    } catch (e) {
      if (!_isConnectivityError(e)) rethrow;

      connectivityQueueService.enqueue(
        _DeleteFullSchedulePendingAction(remoteDataSource: remoteDataSource),
      );
    }
  }

  @override
  Future<void> clearLocalSchedule() {
    return localDataSource.clearSchedule();
  }

  @override
  Future<void> deleteScheduleClass({required String classId}) async {
    await localDataSource.deleteClass(classId: classId);

    try {
      await remoteDataSource.deleteScheduleClass(classId: classId);
    } catch (e) {
      if (!_isConnectivityError(e)) rethrow;

      connectivityQueueService.enqueue(
        _DeleteScheduleClassPendingAction(
          remoteDataSource: remoteDataSource,
          classId: classId,
        ),
      );
    }
  }

  @override
  Future<void> deleteScheduleOccurrence({
    required String classId,
    required DateTime date,
  }) async {
    await localDataSource.deleteOccurrence(classId: classId, date: date);

    try {
      await remoteDataSource.deleteScheduleOccurrence(
        classId: classId,
        date: date,
      );
    } catch (e) {
      if (!_isConnectivityError(e)) rethrow;

      connectivityQueueService.enqueue(
        _DeleteScheduleOccurrencePendingAction(
          remoteDataSource: remoteDataSource,
          classId: classId,
          date: date,
        ),
      );
    }
  }

  @override
  Future<void> deleteScheduleOccurrencesFromDate({
    required String classId,
    required DateTime date,
  }) async {
    await localDataSource.deleteOccurrencesFromDate(
      classId: classId,
      date: date,
    );

    final localClasses = await localDataSource.getClasses();
    final normalizedModels = _scheduleClassesToManualModels(localClasses);

    try {
      await remoteDataSource.uploadManualSchedule(classes: normalizedModels);
    } catch (e) {
      if (!_isConnectivityError(e)) rethrow;

      connectivityQueueService.enqueue(
        _UploadManualSchedulePendingAction(
          remoteDataSource: remoteDataSource,
          classes: normalizedModels,
        ),
      );
    }
  }

  @override
  Future<(List<RoomSearchItem>, DateTime?)> getRecommendedRoomsForDay({
    required DateTime date,
  }) async {
    try {
      final raw = await remoteDataSource.getRecommendedRoomsForDay(date: date);

      await localDataSource.cacheRecommendedRooms(date: date, raw: raw);

      return (await compute(_mapRecommendedRoomsFromRaw, raw), DateTime.now());
    } catch (e) {
      if (!_isConnectivityError(e)) rethrow;

      final cached = await localDataSource.getCachedRecommendedRooms(
        date: date,
      );
      final raw = cached.$1;
      final updatedAt = cached.$2;

      if (raw == null) {
        return (<RoomSearchItem>[], null);
      }

      return (await compute(_mapRecommendedRoomsFromRaw, raw), updatedAt);
    }
  }

  @override
  Future<void> refreshScheduleClassesFromRemote() async {
    final remoteClasses = await remoteDataSource.getScheduleClasses();

    await localDataSource.replaceClasses(
      classes: ScheduleClassMapper.toEntityList(remoteClasses),
    );
  }
}

List<ManualClassModel> _scheduleClassesToManualModels(
  List<ScheduleClass> classes,
) {
  return _normalizeManualModelsForBackend(
    classes.map((scheduleClass) {
      return ManualClassModel(
        title: scheduleClass.title ?? 'Class',
        locationText: scheduleClass.locationText,
        roomId: scheduleClass.roomId ?? scheduleClass.locationText,
        startDate: scheduleClass.startDate,
        endDate: scheduleClass.endDate,
        startTime: scheduleClass.startTime,
        endTime: scheduleClass.endTime,
        weekdays: scheduleClass.weekdays,
      );
    }).toList(),
  );
}

List<ManualClassModel> _normalizeManualModelsForBackend(
  List<ManualClassModel> models,
) {
  return models.map((model) {
    final locationText = model.locationText?.trim();
    final roomId = model.roomId?.trim();

    return ManualClassModel(
      title: model.title,
      locationText: locationText,
      roomId: roomId == null || roomId.isEmpty ? locationText : roomId,
      startDate: model.startDate,
      endDate: model.endDate,
      startTime: model.startTime,
      endTime: model.endTime,
      weekdays: model.weekdays
          .map((e) => e.toString().toLowerCase().trim())
          .toList(),
    );
  }).toList();
}

class _UploadManualSchedulePendingAction implements PendingAction {
  final ScheduleRemoteDataSource remoteDataSource;
  final List<dynamic> classes;

  const _UploadManualSchedulePendingAction({
    required this.remoteDataSource,
    required this.classes,
  });

  @override
  String get successMessage => 'Schedule synced correctly.';

  @override
  String get failureMessage => 'We could not sync the schedule.';

  @override
  Future<void> execute() {
    return remoteDataSource.uploadManualSchedule(
      classes: _normalizeManualModelsForBackend(
        classes.cast<ManualClassModel>(),
      ),
    );
  }
}

class _DeleteFullSchedulePendingAction implements PendingAction {
  final ScheduleRemoteDataSource remoteDataSource;

  const _DeleteFullSchedulePendingAction({required this.remoteDataSource});

  @override
  @override
  String get successMessage => 'Schedule deleted correctly.';

  @override
  String get failureMessage => 'We could not sync the schedule deletion.';

  @override
  Future<void> execute() {
    return remoteDataSource.deleteFullSchedule();
  }
}

class _DeleteScheduleClassPendingAction implements PendingAction {
  final ScheduleRemoteDataSource remoteDataSource;
  final String classId;

  const _DeleteScheduleClassPendingAction({
    required this.remoteDataSource,
    required this.classId,
  });

  @override
  String get successMessage => 'Schedule class synced correctly.';

  @override
  String get failureMessage => 'We could not sync the deleted class.';

  @override
  Future<void> execute() {
    if (classId.startsWith('manual_')) {
      return Future.value();
    }

    return remoteDataSource.deleteScheduleClass(classId: classId);
  }
}

class _DeleteScheduleOccurrencePendingAction implements PendingAction {
  final ScheduleRemoteDataSource remoteDataSource;
  final String classId;
  final DateTime date;

  const _DeleteScheduleOccurrencePendingAction({
    required this.remoteDataSource,
    required this.classId,
    required this.date,
  });

  @override
  String get successMessage => 'Schedule occurrence synced correctly.';

  @override
  String get failureMessage => 'We could not sync the deleted occurrence.';

  @override
  Future<void> execute() {
    if (classId.startsWith('manual_')) {
      return Future.value();
    }

    return remoteDataSource.deleteScheduleOccurrence(
      classId: classId,
      date: date,
    );
  }
}

List<RoomSearchItem> _mapRecommendedRoomsFromRaw(Map<String, dynamic> raw) {
  return RecommendedRoomsMapper.fromRaw(raw);
}
