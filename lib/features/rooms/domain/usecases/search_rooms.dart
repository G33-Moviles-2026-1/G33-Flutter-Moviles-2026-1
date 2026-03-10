import '../entities/room_search.dart';
import '../repositories/rooms_repository.dart';

class SearchRooms {
  const SearchRooms(this._repository);

  final RoomRepository _repository;

  Future<RoomSearchResponse> call(RoomSearchRequest request) {
    return _repository.searchRooms(request);
  }
}