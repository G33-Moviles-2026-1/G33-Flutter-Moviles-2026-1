import '../repositories/schedule_repository.dart';
import 'get_authenticated_user_email_usecase.dart';

class ImportIcsForCurrentUserUseCase {
  final ScheduleRepository repository;
  final GetAuthenticatedUserEmailUseCase getAuthenticatedUserEmail;

  ImportIcsForCurrentUserUseCase({
    required this.repository,
    required this.getAuthenticatedUserEmail,
  });

  Future<void> call({required String filePath}) async {
    final userEmail = await getAuthenticatedUserEmail();

    await repository.uploadIcsSchedule(
      userEmail: userEmail,
      filePath: filePath,
    );
  }
}