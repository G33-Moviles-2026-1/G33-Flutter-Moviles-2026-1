import '../entities/room_date_availability.dart';
import '../entities/room_search.dart';

abstract class RoomRepository {
  Future<RoomSearchResponse> searchRooms(RoomSearchRequest request);

  Future<RoomDateAvailability> fetchRoomDateAvailability({
    required String roomId,
    required String date,
  });
}