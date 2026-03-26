import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import '../repositories/schedule_repository.dart';

class GetRecommendedRoomsForDay {
  final ScheduleRepository repository;

  GetRecommendedRoomsForDay(this.repository);

  Future<List<RoomSearchItem>> call({
    required String userEmail,
    required DateTime date,
  }) {
    return repository.getRecommendedRoomsForDay(
      userEmail: userEmail,
      date: date,
    );
  }
}