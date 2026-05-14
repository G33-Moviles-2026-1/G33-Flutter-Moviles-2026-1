import '../entities/google_calendar_source.dart';
import '../repositories/schedule_repository.dart';

class GetGoogleCalendarsForCurrentUserUseCase {
  final ScheduleRepository repository;

  const GetGoogleCalendarsForCurrentUserUseCase({required this.repository});

  Future<List<GoogleCalendarSource>> call({required String state}) {
    return repository.getGoogleCalendars(state: state);
  }
}
