import '../entities/room_recommendation.dart';
import '../entities/room_search.dart';
import '../repositories/rooms_repository.dart';

class AutoSearchRooms {
  const AutoSearchRooms(this._repository);

  final RoomRepository _repository;

  Future<List<RoomSearchItem>> call(AutoSearchRoomsRequest request) {
    return _repository.autoSearchRooms(request);
  }
}
