import '../repositories/schedule_repository.dart';
import 'get_authenticated_user_email_usecase.dart';

class DeleteScheduleOccurrenceForCurrentUserUseCase {
  final ScheduleRepository repository;
  final GetAuthenticatedUserEmailUseCase getAuthenticatedUserEmail;

  DeleteScheduleOccurrenceForCurrentUserUseCase({
    required this.repository,
    required this.getAuthenticatedUserEmail,
  });

  Future<void> call({
    required String classId,
    required DateTime date,
  }) async {
    final userEmail = await getAuthenticatedUserEmail();

    await repository.deleteScheduleOccurrence(
      userEmail: userEmail,
      classId: classId,
      date: date,
    );
  }
}