import 'package:andespace/features/rooms/domain/entities/room_search.dart';

import '../repositories/schedule_repository.dart';

class GetRecommendedRoomsForCurrentUserUseCase {
  final ScheduleRepository repository;

  GetRecommendedRoomsForCurrentUserUseCase({
    required this.repository,
  });

  Future<List<RoomSearchItem>> call({required DateTime date}) async {

    return repository.getRecommendedRoomsForDay(
      date: date,
    );
  }
}