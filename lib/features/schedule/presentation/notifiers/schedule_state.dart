import 'package:andespace/features/schedule/domain/entities/weekly_schedule.dart';

import '../../domain/entities/schedule_occurrence.dart';

enum ScheduleStatus {
  initial,
  loading,
  loaded,
  empty,
  uploading,
  savingManualClass,
  deleting,
  error,
}

class ScheduleDayOccurrences {
  final DateTime day;
  final List<ScheduleOccurrence> occurrences;

  const ScheduleDayOccurrences({required this.day, required this.occurrences});
}

class ScheduleState {
  final ScheduleStatus status;
  final WeeklySchedule? weeklySchedule;
  final List<ScheduleDayOccurrences> weekDays;
  final DateTime selectedDate;
  final String? errorMessage;
  final String? ownerEmail;
  final String? infoMessage;
  final bool hasInternetConnection;
  final bool isLoadingRecommendations;

  const ScheduleState({
    required this.status,
    required this.selectedDate,
    this.weekDays = const [],
    this.weeklySchedule,
    this.errorMessage,
    this.ownerEmail,
    this.infoMessage,
    this.hasInternetConnection = true,
    this.isLoadingRecommendations = false,
  });

  factory ScheduleState.initial() {
    final now = DateTime.now();
    return ScheduleState(
      status: ScheduleStatus.initial,
      selectedDate: DateTime(now.year, now.month, now.day),
      weeklySchedule: null,
      weekDays: const [],
      errorMessage: null,
      ownerEmail: null,
      infoMessage: null,
      hasInternetConnection: true,
      isLoadingRecommendations: false,
    );
  }

  ScheduleState copyWith({
    ScheduleStatus? status,
    WeeklySchedule? weeklySchedule,
    List<ScheduleDayOccurrences>? weekDays,
    bool clearWeeklySchedule = false,
    DateTime? selectedDate,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? ownerEmail,
    bool clearOwnerEmail = false,
    String? infoMessage,
    bool clearInfoMessage = false,
    bool? hasInternetConnection,
    bool? isLoadingRecommendations,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      weeklySchedule: clearWeeklySchedule
          ? null
          : (weeklySchedule ?? this.weeklySchedule),
      weekDays: clearWeeklySchedule ? const [] : (weekDays ?? this.weekDays),
      selectedDate: selectedDate ?? this.selectedDate,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      ownerEmail: clearOwnerEmail ? null : (ownerEmail ?? this.ownerEmail),
      infoMessage: clearInfoMessage ? null : (infoMessage ?? this.infoMessage),
      hasInternetConnection:
          hasInternetConnection ?? this.hasInternetConnection,
      isLoadingRecommendations:
          isLoadingRecommendations ?? this.isLoadingRecommendations,
    );
  }
}
