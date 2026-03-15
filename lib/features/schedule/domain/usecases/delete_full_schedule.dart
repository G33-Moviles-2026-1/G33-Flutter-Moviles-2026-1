import '../repositories/schedule_repository.dart';

class DeleteFullSchedule {
  final ScheduleRepository repository;

  const DeleteFullSchedule(this.repository);

  Future<void> call({
    required String userEmail,
  }) {
    return repository.deleteFullSchedule(
      userEmail: userEmail,
    );
  }
}