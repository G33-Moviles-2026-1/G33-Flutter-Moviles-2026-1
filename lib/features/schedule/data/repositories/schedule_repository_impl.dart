import 'package:andespace/core/connectivity/connectivity_queue_service.dart';
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

  static const _pendingUploadManualSchedule = 'upload_manual_schedule';
  static const _pendingDeleteFullSchedule = 'delete_full_schedule';
  static const _pendingDeleteScheduleClass = 'delete_schedule_class';
  static const _pendingDeleteScheduleOccurrence = 'delete_schedule_occurrence';

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
      await localDataSource.enqueuePendingScheduleMutation(
        type: _pendingUploadManualSchedule,
        payload: {'classes': normalizedModels.map((e) => e.toJson()).toList()},
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
      await localDataSource.enqueuePendingScheduleMutation(
        type: _pendingDeleteFullSchedule,
        payload: const {},
      );
    }
  }

  @override
  Future<void> clearLocalSchedule() async {
    await Future.wait([
      localDataSource.clearSchedule(),
      localDataSource.clearPendingScheduleMutations(),
    ]);
  }

  @override
  Future<void> deleteScheduleClass({required String classId}) async {
    await localDataSource.deleteClass(classId: classId);

    try {
      await remoteDataSource.deleteScheduleClass(classId: classId);
    } catch (e) {
      if (!_isConnectivityError(e)) rethrow;
      await localDataSource.enqueuePendingScheduleMutation(
        type: _pendingDeleteScheduleClass,
        payload: {'class_id': classId},
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
      await localDataSource.enqueuePendingScheduleMutation(
        type: _pendingDeleteScheduleOccurrence,
        payload: {'class_id': classId, 'date': _dateOnlyIso(date)},
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
      await localDataSource.enqueuePendingScheduleMutation(
        type: _pendingUploadManualSchedule,
        payload: {'classes': normalizedModels.map((e) => e.toJson()).toList()},
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

  @override
  Future<void> syncPendingScheduleMutations() async {
    final pending = await localDataSource.getPendingScheduleMutations();
    if (pending.isEmpty) return;

    for (final mutation in pending) {
      try {
        await _executePendingScheduleMutation(mutation);
        await localDataSource.removePendingScheduleMutation(mutation.id);
      } catch (e) {
        if (_isConnectivityError(e)) rethrow;
        await localDataSource.removePendingScheduleMutation(mutation.id);
        rethrow;
      }
    }

    await refreshScheduleClassesFromRemote();
  }

  Future<void> _executePendingScheduleMutation(
    PendingScheduleMutation mutation,
  ) {
    switch (mutation.type) {
      case _pendingUploadManualSchedule:
        final classes = _manualModelsFromPayload(mutation.payload['classes']);
        return remoteDataSource.uploadManualSchedule(
          classes: _normalizeManualModelsForBackend(classes),
        );
      case _pendingDeleteFullSchedule:
        return remoteDataSource.deleteFullSchedule();
      case _pendingDeleteScheduleClass:
        final classId = mutation.payload['class_id']?.toString() ?? '';
        if (classId.isEmpty || classId.startsWith('manual_')) {
          return Future.value();
        }
        return remoteDataSource.deleteScheduleClass(classId: classId);
      case _pendingDeleteScheduleOccurrence:
        final classId = mutation.payload['class_id']?.toString() ?? '';
        final date = DateTime.tryParse(
          mutation.payload['date']?.toString() ?? '',
        );
        if (classId.isEmpty || classId.startsWith('manual_') || date == null) {
          return Future.value();
        }
        return remoteDataSource.deleteScheduleOccurrence(
          classId: classId,
          date: date,
        );
      default:
        return Future.value();
    }
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

List<ManualClassModel> _manualModelsFromPayload(Object? raw) {
  if (raw is! List) return const [];

  return raw.whereType<Map>().map((item) {
    final map = Map<String, dynamic>.from(item);

    return ManualClassModel(
      title: map['title']?.toString() ?? 'Class',
      locationText: map['location_text']?.toString(),
      roomId: map['room_id']?.toString(),
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      startTime: map['start_time']?.toString() ?? '',
      endTime: map['end_time']?.toString() ?? '',
      weekdays: (map['weekdays'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }).toList();
}

String _dateOnlyIso(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

List<RoomSearchItem> _mapRecommendedRoomsFromRaw(Map<String, dynamic> raw) {
  return RecommendedRoomsMapper.fromRaw(raw);
}
