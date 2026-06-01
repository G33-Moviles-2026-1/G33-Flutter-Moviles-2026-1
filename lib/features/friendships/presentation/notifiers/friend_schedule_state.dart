import 'package:andespace/features/schedule/domain/entities/weekly_schedule.dart';

enum FriendScheduleStatus { loading, success, error }

class FriendScheduleState {
  const FriendScheduleState({
    required this.referenceDate,
    this.status = FriendScheduleStatus.loading,
    this.schedule,
    this.errorMessage,
    this.isOffline = false,
    this.lastUpdated,
  });

  final DateTime referenceDate;
  final FriendScheduleStatus status;
  final WeeklySchedule? schedule;
  final String? errorMessage;
  final bool isOffline;
  final DateTime? lastUpdated;

  bool get isLoading => status == FriendScheduleStatus.loading;
  bool get hasError => status == FriendScheduleStatus.error;

  FriendScheduleState copyWith({
    DateTime? referenceDate,
    FriendScheduleStatus? status,
    WeeklySchedule? schedule,
    bool clearSchedule = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isOffline,
    DateTime? lastUpdated,
    bool clearLastUpdated = false,
  }) {
    return FriendScheduleState(
      referenceDate: referenceDate ?? this.referenceDate,
      status: status ?? this.status,
      schedule: clearSchedule ? null : (schedule ?? this.schedule),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      isOffline: isOffline ?? this.isOffline,
      lastUpdated: clearLastUpdated ? null : (lastUpdated ?? this.lastUpdated),
    );
  }
}
