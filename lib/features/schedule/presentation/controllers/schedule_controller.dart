import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/schedule/domain/entities/schedule_class.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andespace/core/analytics/analytics_events.dart';
import 'package:andespace/core/analytics/analytics_service.dart';

import '../../domain/entities/manual_class.dart';
import '../../domain/usecases/delete_full_schedule.dart';
import '../../domain/usecases/delete_schedule_class.dart';
import '../../domain/usecases/delete_schedule_occurrence.dart';
import '../../domain/usecases/get_recommended_rooms_for_day.dart';
import '../../domain/usecases/get_schedule_classes.dart';
import '../../domain/usecases/get_weekly_schedule.dart';
import '../../domain/usecases/upload_ics_schedule.dart';
import '../../domain/usecases/upload_manual_schedule.dart';
import 'schedule_state.dart';

class ScheduleController extends StateNotifier<ScheduleState> {
  final GetWeeklySchedule getWeeklySchedule;
  final UploadIcsSchedule uploadIcsSchedule;
  final UploadManualSchedule uploadManualSchedule;
  final GetScheduleClasses getScheduleClasses;
  final DeleteFullSchedule deleteFullSchedule;
  final DeleteScheduleClass deleteScheduleClass;
  final DeleteScheduleOccurrence deleteScheduleOccurrence;
  final GetRecommendedRoomsForDay getRecommendedRoomsForDay;
  final Future<String> Function() resolveUserEmail;
  final AnalyticsService analyticsService;

  ScheduleController({
    required this.getWeeklySchedule,
    required this.uploadIcsSchedule,
    required this.uploadManualSchedule,
    required this.getScheduleClasses,
    required this.deleteFullSchedule,
    required this.deleteScheduleClass,
    required this.deleteScheduleOccurrence,
    required this.getRecommendedRoomsForDay,
    required this.resolveUserEmail,
    required this.analyticsService,
  }) : super(ScheduleState.initial());

  Future<String> _getUserEmail() async {
    final email = await resolveUserEmail();
    if (email.trim().isEmpty) {
      throw Exception('No authenticated user email found.');
    }
    return email;
  }

  String _extractBackendErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        final detail = data['detail'];

        if (detail is String && detail.trim().isNotEmpty) {
          return detail;
        }

        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;

          if (first is Map<String, dynamic>) {
            final msg = first['msg'];
            if (msg is String && msg.trim().isNotEmpty) {
              return msg;
            }
          }

          return detail.join(', ');
        }
      }

      if (data is String && data.trim().isNotEmpty) {
        return data;
      }

      return error.message ?? 'Something went wrong. Please try again.';
    }

    return error.toString();
  }

  Future<void> _trackScheduleImportStep({
    required String importSessionId,
    required String method,
    required String step,
    required int stepNumber,
    String? errorMessage,
  }) async {
    try {
      final userEmail = await _getUserEmail();

      await analyticsService.trackScheduleImportStep(
        sessionId: importSessionId,
        deviceId: 'mobile',
        userEmail: userEmail,
        method: method,
        step: step,
        stepNumber: stepNumber,
        propsJson: {
          if (errorMessage != null) 'error_message': errorMessage,
        },
      );
    } catch (_) {}
  }

  Future<void> loadWeek({DateTime? date}) async {
    final targetDate = date ?? state.selectedDate;

    state = state.copyWith(
      status: ScheduleStatus.loading,
      selectedDate: targetDate,
      clearErrorMessage: true,
    );

    try {
      final userEmail = await _getUserEmail();

      final schedule = await getWeeklySchedule(
        userEmail: userEmail,
        date: targetDate,
      );

      if (schedule.occurrences.isEmpty) {
        state = state.copyWith(
          status: ScheduleStatus.empty,
          weeklySchedule: schedule,
        );
        return;
      }

      state = state.copyWith(
        status: ScheduleStatus.loaded,
        weeklySchedule: schedule,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      if (statusCode == 404) {
        state = state.copyWith(
          status: ScheduleStatus.empty,
          clearWeeklySchedule: true,
          errorMessage: null,
        );
        return;
      }

      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: _extractBackendErrorMessage(e),
      );
    } catch (e) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: _extractBackendErrorMessage(e),
      );
    }
  }

  Future<void> refresh() async {
    await loadWeek(date: state.selectedDate);
  }

  Future<void> goToPreviousWeek() async {
    final previousWeek = state.selectedDate.subtract(const Duration(days: 7));
    await loadWeek(date: previousWeek);
  }

  Future<void> goToNextWeek() async {
    final nextWeek = state.selectedDate.add(const Duration(days: 7));
    await loadWeek(date: nextWeek);
  }

  Future<void> importIcs({
    required String filePath,
    required String importSessionId,
  }) async {
    state = state.copyWith(
      status: ScheduleStatus.uploading,
      clearErrorMessage: true,
    );

    try {
      final userEmail = await _getUserEmail();

      await uploadIcsSchedule(
        userEmail: userEmail,
        filePath: filePath,
      );

      await _trackScheduleImportStep(
        importSessionId: importSessionId,
        method: 'ics',
        step: 'completed',
        stepNumber: 5,
      );

      await loadWeek(date: DateTime.now());
    } catch (e) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: _extractBackendErrorMessage(e),
      );
    }
  }

  Future<void> saveManualClass({
    required ManualClass manualClass,
    required String importSessionId,
  }) async {
    state = state.copyWith(
      status: ScheduleStatus.savingManualClass,
      clearErrorMessage: true,
    );

    try {
      final userEmail = await _getUserEmail();

      final existingClasses = await getScheduleClasses(userEmail: userEmail);

      final allClasses = [
        ...existingClasses.map(
          (e) => ManualClass(
            title: e.title ?? 'Class',
            locationText: e.locationText,
            roomId: e.roomId,
            startDate: e.startDate,
            endDate: e.endDate,
            startTime: e.startTime,
            endTime: e.endTime,
            weekdays: e.weekdays,
          ),
        ),
        manualClass,
      ];

      await uploadManualSchedule(
        userEmail: userEmail,
        classes: allClasses,
      );

      await _trackScheduleImportStep(
        importSessionId: importSessionId,
        method: 'manual',
        step: 'completed',
        stepNumber: 4,
      );

      await loadWeek(date: state.selectedDate);
    } catch (e) {

      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: _extractBackendErrorMessage(e),
      );
    }
  }

  Future<void> removeFullSchedule() async {
    state = state.copyWith(
      status: ScheduleStatus.deleting,
      clearErrorMessage: true,
    );

    try {
      final userEmail = await _getUserEmail();

      await deleteFullSchedule(userEmail: userEmail);

      state = state.copyWith(
        status: ScheduleStatus.empty,
        clearWeeklySchedule: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: _extractBackendErrorMessage(e),
      );
    }
  }

  Future<void> removeClass({
    required String classId,
  }) async {
    state = state.copyWith(
      status: ScheduleStatus.deleting,
      clearErrorMessage: true,
    );

    try {
      final userEmail = await _getUserEmail();

      await deleteScheduleClass(
        userEmail: userEmail,
        classId: classId,
      );

      await loadWeek(date: state.selectedDate);
    } catch (e) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: _extractBackendErrorMessage(e),
      );
    }
  }

  Future<void> removeOccurrence({
    required String classId,
    required DateTime date,
  }) async {
    state = state.copyWith(
      status: ScheduleStatus.deleting,
      clearErrorMessage: true,
    );

    try {
      final userEmail = await _getUserEmail();

      await deleteScheduleOccurrence(
        userEmail: userEmail,
        classId: classId,
        date: date,
      );

      await loadWeek(date: state.selectedDate);
    } catch (e) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: _extractBackendErrorMessage(e),
      );
    }
  }

  Future<List<ScheduleClass>> getExistingClassesForValidation() async {
    final userEmail = await _getUserEmail();
    return getScheduleClasses(userEmail: userEmail);
  }

  Future<List<RoomSearchItem>> loadRecommendedRoomsForSelectedDay() async {
    try {
      final userEmail = await _getUserEmail();

      final items = await getRecommendedRoomsForDay(
        userEmail: userEmail,
        date: state.selectedDate,
      );

      return items;
    } catch (e) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: _extractBackendErrorMessage(e),
      );
      rethrow;
    }
  }
}