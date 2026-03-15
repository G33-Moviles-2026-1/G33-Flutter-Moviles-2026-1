import '../entities/free_rooms_for_day.dart';
import '../repositories/schedule_repository.dart';

class GetFreeRoomsForDay {
  final ScheduleRepository repository;

  const GetFreeRoomsForDay(this.repository);

  Future<FreeRoomsForDay> call({
    required String userEmail,
    required DateTime date,
  }) {
    return repository.getFreeRoomsForDay(
      userEmail: userEmail,
      date: date,
    );
  }
}