import '../../../rooms/domain/entities/room_search.dart';

class FavoriteRoom {
  const FavoriteRoom({
    required this.roomId,
    required this.buildingCode,
    required this.buildingName,
    required this.roomNumber,
    required this.capacity,
    required this.reliability,
    required this.utilities,
    required this.isPendingSync,
  });

  final String roomId;
  final String buildingCode;
  final String? buildingName;
  final String roomNumber;
  final int capacity;
  final double reliability;
  final List<String> utilities;
  final bool isPendingSync;

  RoomSearchItem toRoomSearchItem() {
    return RoomSearchItem(
      roomId: roomId,
      buildingCode: buildingCode,
      buildingName: buildingName,
      roomNumber: roomNumber,
      capacity: capacity,
      reliability: reliability,
      utilities: utilities,
      distanceSeconds: null,
      matchingWindows: const [],
    );
  }
}