import 'package:andespace/core/analytics/analytics_service.dart';
import 'package:andespace/core/di/auth_providers.dart';
import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/schedule/domain/entities/schedule_class.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/manual_class.dart';
import '../../domain/usecases/delete_full_schedule.dart';
import '../../domain/usecases/delete_schedule_class.dart';
import '../../domain/usecases/delete_schedule_occurrence.dart';
import '../../domain/usecases/get_recommended_rooms_for_day.dart';
import '../../domain/usecases/get_schedule_classes.dart';
import '../../domain/usecases/get_weekly_schedule.dart';
import '../../domain/usecases/upload_ics_schedule.dart';
import '../../domain/usecases/upload_manual_schedule.dart';
import '../providers/schedule_providers.dart';
import 'schedule_state.dart';

class ScheduleNotifier extends Notifier<ScheduleState> {
  late final GetWeeklySchedule _getWeeklySchedule;
  late final UploadIcsSchedule _uploadIcsSchedule;
  late final UploadManualSchedule _uploadManualSchedule;
  late final GetScheduleClasses _getScheduleClasses;
  late final DeleteFullSchedule _deleteFullSchedule;
  late final DeleteScheduleClass _deleteScheduleClass;
  late final DeleteScheduleOccurrence _deleteScheduleOccurrence;
  late final GetRecommendedRoomsForDay _getRecommendedRoomsForDay;
  late final AnalyticsService _analyticsService;

  @override
  ScheduleState build() {
    _getWeeklySchedule = ref.read(getWeeklyScheduleProvider);
    _uploadIcsSchedule = ref.read(uploadIcsScheduleProvider);
    _uploadManualSchedule = ref.read(uploadManualScheduleProvider);
    _getScheduleClasses = ref.read(getScheduleClassesProvider);
    _deleteFullSchedule = ref.read(deleteFullScheduleProvider);
    _deleteScheduleClass = ref.read(deleteScheduleClassProvider);
    _deleteScheduleOccurrence = ref.read(deleteScheduleOccurrenceProvider);
    _getRecommendedRoomsForDay = ref.read(getRecommendedRoomsForDayProvider);
    _analyticsService = ref.read(analyticsServiceProvider);
    return ScheduleState.initial();
  }

  Future<String> getUserEmail() => _getUserEmail();

  Future<String> _getUserEmail() async {
    final getCurrentUser = ref.read(getCurrentUserUseCaseProvider);
    final currentUser = await getCurrentUser();
    final email = currentUser?.email ?? '';
    if (email.trim().isEmpty) throw Exception('No authenticated user email found.');
    return email;
  }

  String _extractBackendErrorMessage(Object error) => DioErrorMapper.map(
        error,
        onBadResponse: (statusCode, detail) {
          if (statusCode == 422) {
            final d = detail?.toLowerCase() ?? '';
            if (d.contains('class start_time must be between 05:30 and 22:00') ||
                d.contains('class end_time must be at or before 22:00') ||
                d.contains('class end_time must be later than start_time')) {
              return 'The class hours must be between 05:30 and 22:00.';
            }
          }
          return 'Something went wrong. Please try again.';
        },
      );

  Future<void> _trackScheduleImportStep({
    required String importSessionId,
    required String method,
    required String step,
    required int stepNumber,
    String? errorMessage,
  }) async {
    try {
      final userEmail = await _getUserEmail();
      await _analyticsService.trackScheduleImportStep(
        sessionId: importSessionId,
        deviceId: 'mobile',
        userEmail: userEmail,
        method: method,
        step: step,
        stepNumber: stepNumber,
        propsJson: {if (errorMessage != null) 'error_message': errorMessage},
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
      final schedule = await _getWeeklySchedule(userEmail: userEmail, date: targetDate);

      if (schedule.occurrences.isEmpty) {
        state = state.copyWith(status: ScheduleStatus.empty, weeklySchedule: schedule);
        return;
      }

      state = state.copyWith(status: ScheduleStatus.loaded, weeklySchedule: schedule);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
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

  Future<void> refresh() async => loadWeek(date: DateTime.now());

  Future<void> selectDay(DateTime date) async {
    state = state.copyWith(
      selectedDate: DateTime(date.year, date.month, date.day),
      clearErrorMessage: true,
    );
  }

  Future<void> goToPreviousWeek() async =>
      loadWeek(date: state.selectedDate.subtract(const Duration(days: 7)));

  Future<void> goToNextWeek() async =>
      loadWeek(date: state.selectedDate.add(const Duration(days: 7)));

  Future<void> importIcs({
    required String filePath,
    required String importSessionId,
  }) async {
    state = state.copyWith(status: ScheduleStatus.uploading, clearErrorMessage: true);
    try {
      final userEmail = await _getUserEmail();
      await _uploadIcsSchedule(userEmail: userEmail, filePath: filePath);
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
    state = state.copyWith(status: ScheduleStatus.savingManualClass, clearErrorMessage: true);
    try {
      final userEmail = await _getUserEmail();
      final existingClasses = await _getScheduleClasses(userEmail: userEmail);

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

      await _uploadManualSchedule(userEmail: userEmail, classes: allClasses);
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
    state = state.copyWith(status: ScheduleStatus.deleting, clearErrorMessage: true);
    try {
      final userEmail = await _getUserEmail();
      await _deleteFullSchedule(userEmail: userEmail);
      state = state.copyWith(status: ScheduleStatus.empty, clearWeeklySchedule: true);
    } catch (e) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: _extractBackendErrorMessage(e),
      );
    }
  }

  Future<void> removeClass({required String classId}) async {
    state = state.copyWith(status: ScheduleStatus.deleting, clearErrorMessage: true);
    try {
      final userEmail = await _getUserEmail();
      await _deleteScheduleClass(userEmail: userEmail, classId: classId);
      await loadWeek(date: state.selectedDate);
    } catch (e) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: _extractBackendErrorMessage(e),
      );
    }
  }

  Future<void> removeOccurrence({required String classId, required DateTime date}) async {
    state = state.copyWith(status: ScheduleStatus.deleting, clearErrorMessage: true);
    try {
      final userEmail = await _getUserEmail();
      await _deleteScheduleOccurrence(userEmail: userEmail, classId: classId, date: date);
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
    return _getScheduleClasses(userEmail: userEmail);
  }

  Future<List<RoomSearchItem>> loadRecommendedRoomsForSelectedDay() async {
    try {
      final userEmail = await _getUserEmail();
      return await _getRecommendedRoomsForDay(userEmail: userEmail, date: state.selectedDate);
    } catch (e) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: _extractBackendErrorMessage(e),
      );
      rethrow;
    }
  }
}

final scheduleControllerProvider =
    NotifierProvider<ScheduleNotifier, ScheduleState>(ScheduleNotifier.new);
