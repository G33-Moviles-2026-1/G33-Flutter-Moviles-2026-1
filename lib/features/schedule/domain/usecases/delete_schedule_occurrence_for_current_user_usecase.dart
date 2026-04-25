import '../repositories/schedule_repository.dart';

class DeleteScheduleOccurrenceForCurrentUserUseCase {
  final ScheduleRepository repository;

  DeleteScheduleOccurrenceForCurrentUserUseCase({
    required this.repository,
  });

  Future<void> call({
    required String classId,
    required DateTime date,
  }) async {
    await repository.deleteScheduleOccurrence(
      classId: classId,
      date: date,
    );
  }
}