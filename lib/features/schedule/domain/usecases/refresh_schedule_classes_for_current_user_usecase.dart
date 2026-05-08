import '../repositories/schedule_repository.dart';

class RefreshScheduleClassesForCurrentUserUseCase {
  final ScheduleRepository repository;

  const RefreshScheduleClassesForCurrentUserUseCase({
    required this.repository,
  });

  Future<void> call() {
    return repository.refreshScheduleClassesFromRemote();
  }
}