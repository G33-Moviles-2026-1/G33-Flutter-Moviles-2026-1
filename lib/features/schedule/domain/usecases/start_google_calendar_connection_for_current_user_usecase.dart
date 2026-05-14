import '../entities/google_calendar_auth_session.dart';
import '../repositories/schedule_repository.dart';

class StartGoogleCalendarConnectionForCurrentUserUseCase {
  final ScheduleRepository repository;

  const StartGoogleCalendarConnectionForCurrentUserUseCase({
    required this.repository,
  });

  Future<GoogleCalendarAuthSession> call() {
    return repository.startGoogleCalendarConnection();
  }
}
