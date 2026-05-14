import '../repositories/schedule_repository.dart';

class ClearLocalScheduleForCurrentUserUseCase {
  final ScheduleRepository repository;

  const ClearLocalScheduleForCurrentUserUseCase({required this.repository});

  Future<void> call() {
    return repository.clearLocalSchedule();
  }
}
