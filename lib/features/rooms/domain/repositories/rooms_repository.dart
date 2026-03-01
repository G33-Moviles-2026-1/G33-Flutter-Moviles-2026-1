import '../entities/room_detail.dart';

abstract class RoomRepository {
  Future<RoomDetail> getRoomDetail(String roomId);
}