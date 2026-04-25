import '../repositories/schedule_repository.dart';
class DeleteFullScheduleForCurrentUserUseCase {
  final ScheduleRepository repository;

  DeleteFullScheduleForCurrentUserUseCase({
    required this.repository,
  });

  Future<void> call() async {

    await repository.deleteFullSchedule();
  }
}