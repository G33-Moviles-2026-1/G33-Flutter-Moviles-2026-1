import '../repositories/schedule_repository.dart';

class SyncPendingScheduleMutationsForCurrentUserUseCase {
  const SyncPendingScheduleMutationsForCurrentUserUseCase({
    required this.repository,
  });

  final ScheduleRepository repository;

  Future<void> call() {
    return repository.syncPendingScheduleMutations();
  }
}
