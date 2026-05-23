import 'package:andespace/core/di/auth_providers.dart';
import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/schedule/domain/entities/google_calendar_auth_session.dart';
import 'package:andespace/features/schedule/domain/entities/google_calendar_source.dart';
import 'package:andespace/features/schedule/domain/entities/schedule_class.dart';
import 'package:andespace/features/schedule/domain/entities/schedule_occurrence.dart';
import 'package:andespace/features/schedule/domain/entities/weekly_schedule.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/manual_class.dart';
import '../../domain/usecases/delete_schedule_occurrence_for_current_user_usecase.dart';
import '../mappers/schedule_error_message_mapper.dart';
import '../providers/schedule_providers.dart';
import 'schedule_state.dart';

class ScheduleNotifier extends Notifier<ScheduleState> {
  @override
  ScheduleState build() {
    return ScheduleState.initial();
  }

  void resetState() {
    state = ScheduleState.initial();
  }

  List<ScheduleDayOccurrences> _buildWeekDays(
    WeeklySchedule schedule, {
    List<ScheduleDayOccurrences> previous = const [],
  }) {
    final grouped = <DateTime, List<ScheduleOccurrence>>{};
    final previousByDay = <String, ScheduleDayOccurrences>{
      for (final dayData in previous) _dateKey(dayData.day): dayData,
    };

    for (final occurrence in schedule.occurrences) {
      if (occurrence.date.weekday == DateTime.sunday) continue;

      final key = DateTime(
        occurrence.date.year,
        occurrence.date.month,
        occurrence.date.day,
      );

      grouped.putIfAbsent(key, () => <ScheduleOccurrence>[]).add(occurrence);
    }

    return List<ScheduleDayOccurrences>.unmodifiable(
      List.generate(6, (index) {
        final day = schedule.weekStart.add(Duration(days: index));
        final key = DateTime(day.year, day.month, day.day);
        final occurrences = grouped[key] ?? const <ScheduleOccurrence>[];
        final previousDay = previousByDay[_dateKey(key)];

        if (previousDay != null &&
            _sameOccurrences(previousDay.occurrences, occurrences)) {
          return previousDay;
        }

        return ScheduleDayOccurrences(
          day: key,
          occurrences: List<ScheduleOccurrence>.unmodifiable(occurrences),
        );
      }),
    );
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  bool _sameOccurrences(
    List<ScheduleOccurrence> first,
    List<ScheduleOccurrence> second,
  ) {
    if (identical(first, second)) return true;
    if (first.length != second.length) return false;

    for (var index = 0; index < first.length; index++) {
      if (!_sameOccurrence(first[index], second[index])) return false;
    }

    return true;
  }

  bool _sameOccurrence(ScheduleOccurrence first, ScheduleOccurrence second) {
    return first.classId == second.classId &&
        first.title == second.title &&
        first.locationText == second.locationText &&
        first.roomId == second.roomId &&
        first.date == second.date &&
        first.weekday == second.weekday &&
        first.startTime == second.startTime &&
        first.endTime == second.endTime;
  }

  Future<void> _trackScheduleImportStep({
    required String importSessionId,
    required String method,
    required String step,
    required int stepNumber,
    Map<String, dynamic>? propsJson,
  }) async {
    try {
      final analyticsService = ref.read(analyticsServiceProvider);

      await analyticsService.trackScheduleImportStep(
        sessionId: importSessionId,
        deviceId: 'mobile',
        userEmail: await _getAnalyticsUserEmail(),
        method: method,
        step: step,
        stepNumber: stepNumber,
        propsJson: propsJson ?? const {},
      );
    } catch (_) {
      // Analytics should never block the main schedule flow.
    }
  }

  Future<String?> _getAnalyticsUserEmail() async {
    try {
      final user = await ref.read(authLocalDataSourceProvider).getSavedUser();
      final email = user?.email.trim();

      if (email == null || email.isEmpty) return null;

      return email;
    } catch (_) {
      return null;
    }
  }

  Future<void> trackManualImportStarted({
    required String importSessionId,
    required String sourceScreen,
  }) {
    return _trackScheduleImportStep(
      importSessionId: importSessionId,
      method: 'manual',
      step: 'started',
      stepNumber: 1,
      propsJson: {'source_screen': sourceScreen},
    );
  }

  Future<void> trackIcsImportStarted({
    required String importSessionId,
    required String sourceScreen,
  }) {
    return _trackScheduleImportStep(
      importSessionId: importSessionId,
      method: 'ics',
      step: 'started',
      stepNumber: 1,
      propsJson: {'source_screen': sourceScreen},
    );
  }

  Future<void> trackIcsFileSelected({
    required String importSessionId,
    required String sourceScreen,
  }) {
    return _trackScheduleImportStep(
      importSessionId: importSessionId,
      method: 'ics',
      step: 'file_selected',
      stepNumber: 2,
      propsJson: {'source_screen': sourceScreen},
    );
  }

  Future<void> trackGoogleImportStarted({
    required String importSessionId,
    required String sourceScreen,
  }) {
    return _trackScheduleImportStep(
      importSessionId: importSessionId,
      method: 'google',
      step: 'started',
      stepNumber: 1,
      propsJson: {'source_screen': sourceScreen},
    );
  }

  Future<void> trackGoogleAuthInitiated({
    required String importSessionId,
    required String sourceScreen,
  }) {
    return _trackScheduleImportStep(
      importSessionId: importSessionId,
      method: 'google',
      step: 'auth_initiated',
      stepNumber: 2,
      propsJson: {'source_screen': sourceScreen},
    );
  }

  Future<void> trackGoogleAuthGranted({
    required String importSessionId,
    required String sourceScreen,
  }) {
    return _trackScheduleImportStep(
      importSessionId: importSessionId,
      method: 'google',
      step: 'auth_granted',
      stepNumber: 3,
      propsJson: {'source_screen': sourceScreen},
    );
  }

  Future<void> trackGoogleCalendarsSelected({
    required String importSessionId,
    required String sourceScreen,
    required int selectedCount,
  }) {
    return _trackScheduleImportStep(
      importSessionId: importSessionId,
      method: 'google',
      step: 'calendar_selected',
      stepNumber: 4,
      propsJson: {
        'source_screen': sourceScreen,
        'selected_count': selectedCount,
      },
    );
  }

  Future<GoogleCalendarAuthSession> startGoogleCalendarConnection() {
    final startConnection = ref.read(
      startGoogleCalendarConnectionForCurrentUserProvider,
    );

    return startConnection();
  }

  Future<List<GoogleCalendarSource>> loadGoogleCalendars({
    required String state,
  }) {
    final getCalendars = ref.read(getGoogleCalendarsForCurrentUserProvider);
    return getCalendars(state: state);
  }

  Future<void> importGoogleCalendars({
    required String oauthState,
    required List<String> calendarIds,
    required String importSessionId,
  }) async {
    state = state.copyWith(
      status: ScheduleStatus.uploading,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );

    try {
      final importGoogle = ref.read(
        importGoogleCalendarsForCurrentUserProvider,
      );

      await importGoogle(state: oauthState, calendarIds: calendarIds);

      await loadWeek(date: DateTime.now());

      await _trackScheduleImportStep(
        importSessionId: importSessionId,
        method: 'google',
        step: 'completed',
        stepNumber: 5,
        propsJson: {'source_screen': 'schedule_load'},
      );
    } catch (error) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: mapScheduleErrorMessage(error),
      );
    }
  }

  Future<void> loadWeek({
    DateTime? date,
    bool refreshFromRemote = false,
  }) async {
    final targetDate = date ?? state.selectedDate;

    state = state.copyWith(
      status: ScheduleStatus.loading,
      selectedDate: targetDate,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );

    try {
      if (refreshFromRemote) {
        try {
          final refreshRemote = ref.read(
            refreshScheduleClassesForCurrentUserProvider,
          );

          await refreshRemote();
        } catch (_) {
          // Local-first fallback: use local schedule.
        }
      }

      final loadWeek = ref.read(loadWeekForCurrentUserProvider);
      final schedule = await loadWeek(date: targetDate);

      if (schedule.occurrences.isEmpty) {
        final existingClasses = await ref.read(
          getScheduleClassesForCurrentUserProvider,
        )();
        final weekDays = _buildWeekDays(schedule, previous: state.weekDays);

        state = state.copyWith(
          status: existingClasses.isEmpty
              ? ScheduleStatus.empty
              : ScheduleStatus.loaded,
          weeklySchedule: schedule,
          weekDays: weekDays,
          clearErrorMessage: true,
          clearInfoMessage: true,
        );
        return;
      }

      state = state.copyWith(
        status: ScheduleStatus.loaded,
        weeklySchedule: schedule,
        weekDays: _buildWeekDays(schedule, previous: state.weekDays),
      );
    } catch (error) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: mapScheduleErrorMessage(error),
        clearWeeklySchedule: true,
      );
    }
  }

  Future<void> refresh() async {
    await loadWeek(date: DateTime.now(), refreshFromRemote: true);
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
      clearInfoMessage: true,
    );

    try {
      final importIcs = ref.read(importIcsForCurrentUserProvider);

      await importIcs(filePath: filePath);

      await _trackScheduleImportStep(
        importSessionId: importSessionId,
        method: 'ics',
        step: 'parsed',
        stepNumber: 3,
        propsJson: {'source_screen': 'schedule_load'},
      );

      await _trackScheduleImportStep(
        importSessionId: importSessionId,
        method: 'ics',
        step: 'confirmed',
        stepNumber: 4,
        propsJson: {'source_screen': 'schedule_load'},
      );

      await loadWeek(date: DateTime.now());

      await _trackScheduleImportStep(
        importSessionId: importSessionId,
        method: 'ics',
        step: 'completed',
        stepNumber: 5,
        propsJson: {'source_screen': 'schedule_load'},
      );
    } catch (error) {
      final message = mapScheduleErrorMessage(error);

      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage:
            message.toLowerCase().contains('internet') ||
                message.toLowerCase().contains('connection')
            ? 'You need internet to import an ICS schedule.'
            : message,
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
      clearInfoMessage: true,
    );

    try {
      final saveManual = ref.read(saveManualClassForCurrentUserProvider);

      await saveManual(manualClass: manualClass);

      await _trackScheduleImportStep(
        importSessionId: importSessionId,
        method: 'manual',
        step: 'first_class_added',
        stepNumber: 2,
        propsJson: {'source_screen': 'add_class'},
      );

      await _trackScheduleImportStep(
        importSessionId: importSessionId,
        method: 'manual',
        step: 'confirmed',
        stepNumber: 3,
        propsJson: {'source_screen': 'add_class'},
      );

      final infoMessage = await _scheduleChangeSuccessMessage();

      await loadWeek(date: state.selectedDate);

      state = state.copyWith(infoMessage: infoMessage);

      await _trackScheduleImportStep(
        importSessionId: importSessionId,
        method: 'manual',
        step: 'completed',
        stepNumber: 4,
        propsJson: {'source_screen': 'add_class'},
      );
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
      clearInfoMessage: true,
    );

    try {
      final infoMessage = await _scheduleChangeSuccessMessage();
      final deleteFull = ref.read(deleteFullScheduleForCurrentUserProvider);
      await deleteFull();

      state = state.copyWith(
        infoMessage: infoMessage,
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

  Future<void> clearLocalSchedule() async {
    final clearLocal = ref.read(clearLocalScheduleForCurrentUserProvider);

    await clearLocal();
    resetState();
  }

  Future<void> removeClass({required String classId}) async {
    state = state.copyWith(
      status: ScheduleStatus.deleting,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );

    try {
      final infoMessage = await _scheduleChangeSuccessMessage();

      final deleteClass = ref.read(deleteScheduleClassForCurrentUserProvider);

      await deleteClass(classId: classId);
      await loadWeek(date: state.selectedDate);

      state = state.copyWith(infoMessage: infoMessage);
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
    ScheduleOccurrenceDeletionScope scope =
        ScheduleOccurrenceDeletionScope.thisEvent,
  }) async {
    state = state.copyWith(
      status: ScheduleStatus.deleting,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );

    try {
      final infoMessage = await _scheduleChangeSuccessMessage();

      final deleteOccurrence = ref.read(
        deleteScheduleOccurrenceForCurrentUserProvider,
      );

      await deleteOccurrence(classId: classId, date: date, scope: scope);
      await loadWeek(date: state.selectedDate);

      state = state.copyWith(infoMessage: infoMessage);
    } catch (error) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: mapScheduleErrorMessage(error),
      );
    }
  }

  Future<List<ScheduleClass>> getExistingClassesForValidation() {
    final getScheduleClasses = ref.read(
      getScheduleClassesForCurrentUserProvider,
    );

    return getScheduleClasses();
  }

  Future<(List<RoomSearchItem>, DateTime?)>
  loadRecommendedRoomsForSelectedDay() async {
    state = state.copyWith(
      isLoadingRecommendations: true,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );

    try {
      await refreshInternetStatus();

      final getRecommendedRooms = ref.read(
        getRecommendedRoomsForCurrentUserProvider,
      );

      return await getRecommendedRooms(date: state.selectedDate);
    } catch (error) {
      state = state.copyWith(
        status: ScheduleStatus.error,
        errorMessage: mapScheduleErrorMessage(error),
      );
      rethrow;
    } finally {
      state = state.copyWith(isLoadingRecommendations: false);
    }
  }

  void clearInfoMessage() {
    state = state.copyWith(clearInfoMessage: true);
  }

  Future<bool> refreshInternetStatus() async {
    final service = ref.read(connectivityStatusServiceProvider);
    final hasConnection = await service.hasInternetConnection();

    state = state.copyWith(hasInternetConnection: hasConnection);

    return hasConnection;
  }

  Future<String> _scheduleChangeSuccessMessage() async {
    final hasConnection = await refreshInternetStatus();

    if (hasConnection) {
      return 'Changes completed successfully.';
    }

    return 'Changes saved locally. Connect to the internet to sync them.';
  }
}

final scheduleControllerProvider =
    NotifierProvider<ScheduleNotifier, ScheduleState>(ScheduleNotifier.new);
