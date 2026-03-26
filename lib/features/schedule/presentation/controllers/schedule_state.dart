import '../../domain/entities/weekly_schedule.dart';

enum ScheduleStatus {
  initial,
  loading,
  empty,
  loaded,
  uploading,
  savingManualClass,
  deleting,
  error,
}

class ScheduleState {
  final ScheduleStatus status;
  final WeeklySchedule? weeklySchedule;
  final DateTime selectedDate;
  final String? errorMessage;

  const ScheduleState({
    required this.status,
    required this.selectedDate,
    this.weeklySchedule,
    this.errorMessage,
  });

  factory ScheduleState.initial() {
    return ScheduleState(
      status: ScheduleStatus.initial,
      selectedDate: DateTime.now(),
    );
  }

  bool get hasSchedule =>
      weeklySchedule != null && weeklySchedule!.occurrences.isNotEmpty;

  ScheduleState copyWith({
    ScheduleStatus? status,
    WeeklySchedule? weeklySchedule,
    DateTime? selectedDate,
    String? errorMessage,
    bool clearWeeklySchedule = false,
    bool clearErrorMessage = false,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      weeklySchedule:
          clearWeeklySchedule ? null : (weeklySchedule ?? this.weeklySchedule),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}