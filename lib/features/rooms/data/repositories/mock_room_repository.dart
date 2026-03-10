import '../../domain/entities/room_detail.dart';
import '../../domain/entities/room_search.dart';
import '../../domain/repositories/rooms_repository.dart';
import '../models/room_dto.dart';

class MockRoomRepository implements RoomRepository {
  @override
  Future<RoomSearchResponse> searchRooms(RoomSearchRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return RoomSearchResponse(
      query: request,
      total: 2,
      items: const [
        RoomSearchItem(
          roomId: 'ML 517',
          buildingCode: 'ML',
          buildingName: 'Mario Laserna',
          roomNumber: '517',
          capacity: 35,
          reliability: 82.5,
          utilities: ['power_outlet', 'blackout', 'videobeam'],
          distanceMeters: 42.7,
          matchingWindows: [
            MatchingWindow(start: '10:00', end: '11:30'),
            MatchingWindow(start: '14:30', end: '16:00'),
          ],
          weeklyAvailability: [
            WeeklyAvailabilityWindow(
              day: 'monday',
              start: '06:30',
              end: '08:00',
              validFrom: '2026-01-05',
              validTo: '2026-05-30',
            ),
            WeeklyAvailabilityWindow(
              day: 'tuesday',
              start: '10:00',
              end: '11:30',
              validFrom: '2026-01-05',
              validTo: '2026-05-30',
            ),
          ],
        ),
        RoomSearchItem(
          roomId: 'ML 512',
          buildingCode: 'ML',
          buildingName: 'Mario Laserna',
          roomNumber: '512',
          capacity: 28,
          reliability: 91.0,
          utilities: ['power_outlet', 'videobeam'],
          distanceMeters: 48.1,
          matchingWindows: [
            MatchingWindow(start: '10:00', end: '11:00'),
          ],
          weeklyAvailability: [
            WeeklyAvailabilityWindow(
              day: 'tuesday',
              start: '10:00',
              end: '11:30',
              validFrom: '2026-01-05',
              validTo: '2026-05-30',
            ),
            WeeklyAvailabilityWindow(
              day: 'thursday',
              start: '08:00',
              end: '09:30',
              validFrom: '2026-01-05',
              validTo: '2026-05-30',
            ),
          ],
        ),
      ],
    );
  }

  @override
  Future<RoomDetail> getRoomDetail(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final mockJson = {
      "id": "ML 517",
      "buildingName": "Mario Laserna",
      "capacity": 35,
      "reliability": 82.5,
      "isCurrentlyAvailable": true,
      "utilities": ["Power Outlets", "Blackout", "Projector"],
      "weeklyAvailability": {
        "monday": [
          {"start": "06:30", "end": "08:00"},
          {"start": "12:00", "end": "13:30"},
          {"start": "13:30", "end": "14:00"}
        ],
        "tuesday": [
          {"start": "10:00", "end": "11:30"},
          {"start": "11:30", "end": "12:00"}
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