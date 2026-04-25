import 'package:andespace/features/schedule/domain/entities/weekly_schedule.dart';

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

class ScheduleState {
  final ScheduleStatus status;
  final WeeklySchedule? weeklySchedule;
  final DateTime selectedDate;
  final String? errorMessage;
  final String? ownerEmail;
  final String? infoMessage;

  const ScheduleState({
    required this.status,
    required this.selectedDate,
    this.weeklySchedule,
    this.errorMessage,
    this.ownerEmail,
    this.infoMessage,
  });

  factory ScheduleState.initial() {
    final now = DateTime.now();
    return ScheduleState(
      status: ScheduleStatus.initial,
      selectedDate: DateTime(now.year, now.month, now.day),
      weeklySchedule: null,
      errorMessage: null,
      ownerEmail: null,
      infoMessage: null,
    );
  }

  ScheduleState copyWith({
    ScheduleStatus? status,
    WeeklySchedule? weeklySchedule,
    bool clearWeeklySchedule = false,
    DateTime? selectedDate,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? ownerEmail,
    bool clearOwnerEmail = false,
    String? infoMessage,
    bool clearInfoMessage = false,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      weeklySchedule:
          clearWeeklySchedule ? null : (weeklySchedule ?? this.weeklySchedule),
      selectedDate: selectedDate ?? this.selectedDate,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      ownerEmail: clearOwnerEmail ? null : (ownerEmail ?? this.ownerEmail),
      infoMessage: clearInfoMessage ? null : (infoMessage ?? this.infoMessage),
    );
  }
}