import '../repositories/schedule_repository.dart';
import 'get_authenticated_user_email_usecase.dart';

class DeleteScheduleClassForCurrentUserUseCase {
  final ScheduleRepository repository;
  final GetAuthenticatedUserEmailUseCase getAuthenticatedUserEmail;

  DeleteScheduleClassForCurrentUserUseCase({
    required this.repository,
    required this.getAuthenticatedUserEmail,
  });

  Future<void> call({required String classId}) async {
    final userEmail = await getAuthenticatedUserEmail();

    await repository.deleteScheduleClass(
      userEmail: userEmail,
      classId: classId,
    );
  }
}