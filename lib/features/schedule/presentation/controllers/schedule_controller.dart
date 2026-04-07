import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/schedule/domain/entities/schedule_class.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'The request is taking longer than expected. Please try again.';

        case DioExceptionType.connectionError:
          return 'No internet connection. Please check your network and try again.';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;

          String? backendDetail;
          if (responseData is Map<String, dynamic>) {
            final detail = responseData['detail'];
            if (detail is String) {
              backendDetail = detail;
            }
          }

          if (statusCode == 404) {
            return 'No schedule was found for this week.';
          }

          if (statusCode == 422) {
            final detail = backendDetail?.toLowerCase() ?? '';

            final isInvalidTimeRange =
                detail.contains('class start_time must be between 05:30 and 22:00') ||
                detail.contains('class end_time must be at or before 22:00') ||
                detail.contains('class end_time must be later than start_time');

            if (isInvalidTimeRange) {
              return 'The class hours must be between 05:30 and 22:00, and the end time must be later than the start time.';
            }
          }

          if (statusCode != null && statusCode >= 500) {
            return 'Our servers are having trouble right now. Please try again in a moment.';
          }

          return 'Something went wrong. Please try again.';

        case DioExceptionType.badCertificate:
          return 'A secure connection could not be established. Please try again later.';

        case DioExceptionType.cancel:
          return 'The request was cancelled. Please try again.';

        case DioExceptionType.unknown:
          final message = error.message?.toLowerCase() ?? '';
          if (message.contains('socketexception') ||
              message.contains('failed host lookup') ||
              message.contains('network is unreachable')) {
            return 'No internet connection. Please check your network and try again.';
          }
          return 'Something went wrong. Please try again.';
      }
    }

    return 'Something went wrong. Please try again.';
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
    await loadWeek(date: DateTime.now());
  }

  Future<void> selectDay(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    state = state.copyWith(
      selectedDate: normalizedDate,
      clearErrorMessage: true,
    );
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