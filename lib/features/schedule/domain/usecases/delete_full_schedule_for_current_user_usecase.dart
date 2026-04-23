import '../repositories/schedule_repository.dart';
import 'get_authenticated_user_email_usecase.dart';

class DeleteFullScheduleForCurrentUserUseCase {
  final ScheduleRepository repository;
  final GetAuthenticatedUserEmailUseCase getAuthenticatedUserEmail;

  DeleteFullScheduleForCurrentUserUseCase({
    required this.repository,
    required this.getAuthenticatedUserEmail,
  });

  Future<void> call() async {
    final userEmail = await getAuthenticatedUserEmail();

    await repository.deleteFullSchedule(
      userEmail: userEmail,
    );
  }
}