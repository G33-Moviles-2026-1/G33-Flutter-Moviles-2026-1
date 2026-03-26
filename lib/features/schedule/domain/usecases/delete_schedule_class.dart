import '../repositories/schedule_repository.dart';

class DeleteScheduleClass {
  final ScheduleRepository repository;

  const DeleteScheduleClass(this.repository);

  Future<void> call({
    required String userEmail,
    required String classId,
  }) {
    return repository.deleteScheduleClass(
      userEmail: userEmail,
      classId: classId,
    );
  }
}