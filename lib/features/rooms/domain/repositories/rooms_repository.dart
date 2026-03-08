import '../entities/room_detail.dart';
import '../entities/room_search.dart';

abstract class RoomRepository {
  Future<RoomSearchResponse> searchRooms(RoomSearchRequest request);

  Future<RoomDetail> getRoomDetail(String roomId);
}