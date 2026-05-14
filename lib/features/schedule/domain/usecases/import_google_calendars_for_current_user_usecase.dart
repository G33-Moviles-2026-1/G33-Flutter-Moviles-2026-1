import '../repositories/schedule_repository.dart';

class ImportGoogleCalendarsForCurrentUserUseCase {
  final ScheduleRepository repository;

  const ImportGoogleCalendarsForCurrentUserUseCase({required this.repository});

  Future<void> call({
    required String state,
    required List<String> calendarIds,
  }) {
    return repository.uploadGoogleCalendarSchedule(
      state: state,
      calendarIds: calendarIds,
    );
  }
}
