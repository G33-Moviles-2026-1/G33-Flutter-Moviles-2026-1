import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/schedule/domain/entities/schedule_class.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andespace/core/connectivity/pending_action_event.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/manual_class.dart';
import '../mappers/schedule_error_message_mapper.dart';
import '../providers/schedule_providers.dart';
import 'schedule_state.dart';

class ScheduleNotifier extends Notifier<ScheduleState> {
  @override
  ScheduleState build() {
    Future.microtask(listenPendingActionEvents);
    return ScheduleState.initial();
  }

  Future<String> getUserEmail() {
    final useCase = ref.read(getAuthenticatedUserEmailProvider);
    return useCase();
  }

  void resetState() {
    state = ScheduleState.initial();
  }

  Future<void> _trackScheduleImportStep({
    required String importSessionId,
    required String method,
    required String step,
    required int stepNumber,
    String? errorMessage,
  }) async {
    try {
      final userEmail = await getUserEmail();
      final analyticsService = ref.read(analyticsServiceProvider);

      await analyticsService.trackScheduleImportStep(
        sessionId: importSessionId,
        deviceId: 'mobile',
        userEmail: userEmail,
        method: method,
        step: step,
        stepNumber: stepNumber,
        propsJson: {if (errorMessage != null) 'error_message': errorMessage},
      );
    } catch (_) {
      // No bloqueamos el flujo principal por analytics
    }
  }

  bool _isMissingScheduleError(Object error) {
    if (error is! DioException) return false;

    final statusCode = error.response?.statusCode;
    return statusCode == 404;
  }

  Future<void> loadWeek({DateTime? date}) async {
    final targetDate = date ?? state.selectedDate;
    final userEmail = await getUserEmail();

    // Si cambió el usuario, limpiamos el estado visible para no mezclar sesiones
    if (state.ownerEmail != null && state.ownerEmail != userEmail) {
      state = ScheduleState.initial().copyWith(
        selectedDate: targetDate,
        ownerEmail: userEmail,
      );
    } else if (state.ownerEmail == null) {
      state = state.copyWith(ownerEmail: userEmail);
    }

    state = state.copyWith(
      status: ScheduleStatus.loading,
      selectedDate: targetDate,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );

    try {
      final loadWeekForCurrentUser = ref.read(loadWeekForCurrentUserProvider);
      final schedule = await loadWeekForCurrentUser(date: targetDate);

      if (schedule.occurrences.isEmpty) {
        state = state.copyWith(
          status: ScheduleStatus.empty,
          weeklySchedule: schedule,
          ownerEmail: userEmail,
          clearErrorMessage: true,
          clearInfoMessage: true,
        );
        return;
      }

      state = state.copyWith(
        status: ScheduleStatus.loaded,
        weeklySchedule: schedule,
        ownerEmail: userEmail,
        clearErrorMessage: true,
        clearInfoMessage: true,
      );
    } catch (error) {
      // ESTE es el comportamiento viejo que sí funcionaba:
      // si el backend responde 404 porque no hay horario, no es error; es estado vacío.
      if (_isMissingScheduleError(error)) {
        state = state.copyWith(
          status: ScheduleStatus.empty,
          clearWeeklySchedule: true,
          clearErrorMessage: true,
          clearInfoMessage: true,
          ownerEmail: userEmail,
        );
        return;
      }

      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: mapScheduleErrorMessage(error),
        clearWeeklySchedule: true,
        clearInfoMessage: true,
        ownerEmail: userEmail,
      );
    }
  }

  Future<void> refresh() async {
    await loadWeek(date: DateTime.now());
  }

  Future<void> selectDay(DateTime date) async {
    state = state.copyWith(
      selectedDate: DateTime(date.year, date.month, date.day),
      clearErrorMessage: true,
    );
  }

  Future<void> goToPreviousWeek() async {
    await loadWeek(date: state.selectedDate.subtract(const Duration(days: 7)));
  }

  Future<void> goToNextWeek() async {
    await loadWeek(date: state.selectedDate.add(const Duration(days: 7)));
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
      final importIcsForCurrentUser = ref.read(importIcsForCurrentUserProvider);
      await importIcsForCurrentUser(filePath: filePath);

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
      final saveManualClassForCurrentUser = ref.read(
        saveManualClassForCurrentUserProvider,
      );

      await saveManualClassForCurrentUser(manualClass: manualClass);

      state = state.copyWith(
        infoMessage:
            'Schedule saved. If you are offline, it will sync when connection returns.',
      );

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
      final deleteFullScheduleForCurrentUser = ref.read(
        deleteFullScheduleForCurrentUserProvider,
      );

      await deleteFullScheduleForCurrentUser();

      state = state.copyWith(
        infoMessage:
            'Schedule deleted locally. If you are offline, the change will sync later.',
      );

      state = state.copyWith(
        status: ScheduleStatus.empty,
        clearWeeklySchedule: true,
        clearErrorMessage: true,
        clearOwnerEmail: true,
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
      final deleteScheduleClassForCurrentUser = ref.read(
        deleteScheduleClassForCurrentUserProvider,
      );

      await deleteScheduleClassForCurrentUser(classId: classId);
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
      final deleteScheduleOccurrenceForCurrentUser = ref.read(
        deleteScheduleOccurrenceForCurrentUserProvider,
      );

      await deleteScheduleOccurrenceForCurrentUser(
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
    final getScheduleClassesForCurrentUser = ref.read(
      getScheduleClassesForCurrentUserProvider,
    );

    return getScheduleClassesForCurrentUser();
  }

  Future<List<RoomSearchItem>> loadRecommendedRoomsForSelectedDay() async {
    try {
      final getRecommendedRoomsForCurrentUser = ref.read(
        getRecommendedRoomsForCurrentUserProvider,
      );

      return await getRecommendedRoomsForCurrentUser(date: state.selectedDate);
    } catch (error) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: mapScheduleErrorMessage(error),
      );
      rethrow;
    }
  }

  void listenPendingActionEvents() {
    ref.listen(
      connectivityQueueServiceProvider.select((service) => service.events),
      (_, stream) {
        stream.listen((event) {
          if (event is PendingActionSucceeded) {
            state = state.copyWith(
              infoMessage: event.action.successMessage,
              clearErrorMessage: true,
            );
          }

          if (event is PendingActionFailed) {
            state = state.copyWith(
              errorMessage: event.action.failureMessage,
              clearInfoMessage: true,
            );
          }
        });
      },
    );
  }

  void clearInfoMessage() {
    state = state.copyWith(clearInfoMessage: true);
  }
}

final scheduleControllerProvider =
    NotifierProvider<ScheduleNotifier, ScheduleState>(ScheduleNotifier.new);
