import '../entities/weekly_schedule.dart';
import '../repositories/schedule_repository.dart';
import 'get_authenticated_user_email_usecase.dart';

class LoadWeekForCurrentUserUseCase {
  final ScheduleRepository repository;
  final GetAuthenticatedUserEmailUseCase getAuthenticatedUserEmail;

  LoadWeekForCurrentUserUseCase({
    required this.repository,
    required this.getAuthenticatedUserEmail,
  });

  Future<WeeklySchedule> call({required DateTime date}) async {
    final userEmail = await getAuthenticatedUserEmail();

    return repository.getWeeklySchedule(
      userEmail: userEmail,
      date: date,
    );
  }
}