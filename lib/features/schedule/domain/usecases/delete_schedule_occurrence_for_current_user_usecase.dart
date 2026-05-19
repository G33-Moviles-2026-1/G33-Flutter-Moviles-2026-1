import '../repositories/schedule_repository.dart';

enum ScheduleOccurrenceDeletionScope { thisEvent, thisAndFollowing, allEvents }

class DeleteScheduleOccurrenceForCurrentUserUseCase {
  final ScheduleRepository repository;

  DeleteScheduleOccurrenceForCurrentUserUseCase({required this.repository});

  Future<void> call({
    required String classId,
    required DateTime date,
    ScheduleOccurrenceDeletionScope scope =
        ScheduleOccurrenceDeletionScope.thisEvent,
  }) async {
    switch (scope) {
      case ScheduleOccurrenceDeletionScope.thisEvent:
        await repository.deleteScheduleOccurrence(classId: classId, date: date);
      case ScheduleOccurrenceDeletionScope.thisAndFollowing:
        await repository.deleteScheduleOccurrencesFromDate(
          classId: classId,
          date: date,
        );
      case ScheduleOccurrenceDeletionScope.allEvents:
        await repository.deleteScheduleClass(classId: classId);
    }
  }
}
