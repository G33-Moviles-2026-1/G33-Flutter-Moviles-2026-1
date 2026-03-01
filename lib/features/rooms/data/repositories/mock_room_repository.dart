import '../../domain/entities/room_detail.dart';
import '../../domain/repositories/rooms_repository.dart';
import '../models/room_dto.dart';

class MockRoomRepository implements RoomRepository {
  @override
  Future<RoomDetail> getRoomDetail(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final mockJson = {
      "id": "ML 517",
      "buildingName": "Mario Laserna",
      "capacity": 35,
      "reliability": 82.5,
      "isCurrentlyAvailable": true,
      "utilities": [
        "Power Outlets",
        "Blackout",
        "Projector"
      ],
      "weeklyAvailability": {
        "monday": [
          {"start": "06:30", "end": "08:00"},
          {"start": "12:00", "end": "14:00"}
        ],
        "tuesday": [
          {"start": "10:00", "end": "12:00"}
        ],
        "wednesday": [],
        "thursday": [
          {"start": "08:00", "end": "09:30"}
        ],
        "friday": [],
        "saturday": [],
        "sunday": []
      }
    };

    final dto = RoomDetailDto.fromJson(mockJson);

    return dto.toDomain();
  }
}