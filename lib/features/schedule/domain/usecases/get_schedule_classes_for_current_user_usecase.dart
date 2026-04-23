import '../entities/schedule_class.dart';
import '../repositories/schedule_repository.dart';
import 'get_authenticated_user_email_usecase.dart';

class GetScheduleClassesForCurrentUserUseCase {
  final ScheduleRepository repository;
  final GetAuthenticatedUserEmailUseCase getAuthenticatedUserEmail;

  GetScheduleClassesForCurrentUserUseCase({
    required this.repository,
    required this.getAuthenticatedUserEmail,
  });

  Future<List<ScheduleClass>> call() async {
    final userEmail = await getAuthenticatedUserEmail();

    return repository.getScheduleClasses(
      userEmail: userEmail,
    );
  }
}