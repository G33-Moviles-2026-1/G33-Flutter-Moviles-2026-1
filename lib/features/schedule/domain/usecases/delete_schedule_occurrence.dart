import '../repositories/schedule_repository.dart';

class DeleteScheduleOccurrence {
  final ScheduleRepository repository;

  const DeleteScheduleOccurrence(this.repository);

  Future<void> call({
    required String userEmail,
    required String classId,
    required DateTime date,
  }) {
    return repository.deleteScheduleOccurrence(
      userEmail: userEmail,
      classId: classId,
      date: date,
    );
  }
}