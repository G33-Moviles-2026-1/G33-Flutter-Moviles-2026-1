import 'package:andespace/core/analytics/analytics_service.dart';
import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/schedule/domain/entities/schedule_class.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/manual_class.dart';
import '../../domain/usecases/delete_full_schedule_for_current_user_usecase.dart';
import '../../domain/usecases/delete_schedule_class_for_current_user_usecase.dart';
import '../../domain/usecases/delete_schedule_occurrence_for_current_user_usecase.dart';
import '../../domain/usecases/get_authenticated_user_email_usecase.dart';
import '../../domain/usecases/get_recommended_rooms_for_current_user_usecase.dart';
import '../../domain/usecases/get_schedule_classes_for_current_user_usecase.dart';
import '../../domain/usecases/import_ics_for_current_user_usecase.dart';
import '../../domain/usecases/load_week_for_current_user_usecase.dart';
import '../../domain/usecases/save_manual_class_for_current_user_usecase.dart';
import '../mappers/schedule_error_message_mapper.dart';
import '../providers/schedule_providers.dart';
import 'schedule_state.dart';

class ScheduleNotifier extends Notifier<ScheduleState> {
  late final LoadWeekForCurrentUserUseCase _loadWeekForCurrentUser;
  late final ImportIcsForCurrentUserUseCase _importIcsForCurrentUser;
  late final SaveManualClassForCurrentUserUseCase
      _saveManualClassForCurrentUser;
  late final GetScheduleClassesForCurrentUserUseCase
      _getScheduleClassesForCurrentUser;
  late final DeleteFullScheduleForCurrentUserUseCase
      _deleteFullScheduleForCurrentUser;
  late final DeleteScheduleClassForCurrentUserUseCase
      _deleteScheduleClassForCurrentUser;
  late final DeleteScheduleOccurrenceForCurrentUserUseCase
      _deleteScheduleOccurrenceForCurrentUser;
  late final GetRecommendedRoomsForCurrentUserUseCase
      _getRecommendedRoomsForCurrentUser;
  late final GetAuthenticatedUserEmailUseCase _getAuthenticatedUserEmail;
  late final AnalyticsService _analyticsService;

  @override
  ScheduleState build() {
    _loadWeekForCurrentUser = ref.read(loadWeekForCurrentUserProvider);
    _importIcsForCurrentUser = ref.read(importIcsForCurrentUserProvider);
    _saveManualClassForCurrentUser =
        ref.read(saveManualClassForCurrentUserProvider);
    _getScheduleClassesForCurrentUser =
        ref.read(getScheduleClassesForCurrentUserProvider);
    _deleteFullScheduleForCurrentUser =
        ref.read(deleteFullScheduleForCurrentUserProvider);
    _deleteScheduleClassForCurrentUser =
        ref.read(deleteScheduleClassForCurrentUserProvider);
    _deleteScheduleOccurrenceForCurrentUser =
        ref.read(deleteScheduleOccurrenceForCurrentUserProvider);
    _getRecommendedRoomsForCurrentUser =
        ref.read(getRecommendedRoomsForCurrentUserProvider);
    _getAuthenticatedUserEmail = ref.read(getAuthenticatedUserEmailProvider);
    _analyticsService = ref.read(analyticsServiceProvider);

    return ScheduleState.initial();
  }

  Future<String> getUserEmail() => _getAuthenticatedUserEmail();

  Future<void> _trackScheduleImportStep({
    required String importSessionId,
    required String method,
    required String step,
    required int stepNumber,
    String? errorMessage,
  }) async {
    try {
      final userEmail = await _getAuthenticatedUserEmail();

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
      final schedule = await _loadWeekForCurrentUser(date: targetDate);

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
    } catch (error) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: mapScheduleErrorMessage(error),
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
    state = state.copyWith(
      status: ScheduleStatus.uploading,
      clearErrorMessage: true,
    );

    try {
      await _importIcsForCurrentUser(filePath: filePath);

      await _trackScheduleImportStep(
        importSessionId: importSessionId,
        method: 'ics',
        step: 'completed',
        stepNumber: 5,
      );

      await loadWeek(date: DateTime.now());
    } catch (error) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: mapScheduleErrorMessage(error),
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
      await _saveManualClassForCurrentUser(manualClass: manualClass);

      await _trackScheduleImportStep(
        importSessionId: importSessionId,
        method: 'manual',
        step: 'completed',
        stepNumber: 4,
      );

      await loadWeek(date: state.selectedDate);
    } catch (error) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: mapScheduleErrorMessage(error),
      );
    }
  }

  Future<void> removeFullSchedule() async {
    state = state.copyWith(
      status: ScheduleStatus.deleting,
      clearErrorMessage: true,
    );

    try {
      await _deleteFullScheduleForCurrentUser();

      state = state.copyWith(
        status: ScheduleStatus.empty,
        clearWeeklySchedule: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: mapScheduleErrorMessage(error),
      );
    }
  }

  Future<void> removeClass({required String classId}) async {
    state = state.copyWith(
      status: ScheduleStatus.deleting,
      clearErrorMessage: true,
    );

    try {
      await _deleteScheduleClassForCurrentUser(classId: classId);
      await loadWeek(date: state.selectedDate);
    } catch (error) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: mapScheduleErrorMessage(error),
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
      await _deleteScheduleOccurrenceForCurrentUser(
        classId: classId,
        date: date,
      );
      await loadWeek(date: state.selectedDate);
    } catch (error) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: mapScheduleErrorMessage(error),
      );
    }
  }

  Future<List<ScheduleClass>> getExistingClassesForValidation() {
    return _getScheduleClassesForCurrentUser();
  }

  Future<List<RoomSearchItem>> loadRecommendedRoomsForSelectedDay() async {
    try {
      return await _getRecommendedRoomsForCurrentUser(
        date: state.selectedDate,
      );
    } catch (error) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: mapScheduleErrorMessage(error),
      );
      rethrow;
    }
  }
}

final scheduleControllerProvider =
    NotifierProvider<ScheduleNotifier, ScheduleState>(ScheduleNotifier.new);