import '../entities/room_search.dart';

abstract class RoomRepository {
  Future<RoomSearchResponse> searchRooms(RoomSearchRequest request);
}