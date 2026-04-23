import '../../../rooms/domain/entities/room_search.dart';
import '../../../rooms/domain/entities/time_range.dart';
import 'booking.dart';
import 'booking_purpose.dart';

class MyBooking {
  final String id;
  final String roomId;
  final DateTime date;
  final DateTime createdAt;
  final TimeRange timeRange;
  final BookingPurpose purpose;
  final BookingStatus status;

  const MyBooking({
    required this.id,
    required this.roomId,
    required this.date,
    required this.createdAt,
    required this.timeRange,
    required this.purpose,
    required this.status,
  });

  RoomSearchItem toRoomSearchItem() {
    final parts = roomId.trim().split(RegExp(r'\s+'));
    final buildingCode = parts.isNotEmpty ? parts.first : roomId;
    final roomNumber = parts.length > 1 ? parts.sublist(1).join(' ') : roomId;

    return RoomSearchItem(
      roomId: roomId,
      buildingCode: buildingCode,
      buildingName: null,
      roomNumber: roomNumber,
      capacity: 0,
      reliability: 0,
      utilities: const [],
      distanceSeconds: null,
      matchingWindows: const [],
    );
  }
}