import 'package:andespace/features/rooms/domain/entities/room_search.dart';

class RecommendedRoomsMapper {
  const RecommendedRoomsMapper._();

  static List<RoomSearchItem> fromRaw(Map<String, dynamic> raw) {
    final slots = raw['slots'] as List<dynamic>? ?? [];
    final items = <RoomSearchItem>[];

    for (final slot in slots) {
      final slotMap = Map<String, dynamic>.from(slot as Map);
      final slotStart = slotMap['slot_start'] as String? ?? '';
      final slotEnd = slotMap['slot_end'] as String? ?? '';

      final recommendedRooms =
          slotMap['recommended_rooms'] as List<dynamic>? ?? [];

      for (final room in recommendedRooms) {
        final roomMap = Map<String, dynamic>.from(room as Map);

        final roomId = roomMap['room_id'] as String? ?? '';
        final buildingName = roomMap['building_name'] as String?;
        final capacity = roomMap['capacity'] as int? ?? 0;
        final reliability =
            (roomMap['reliability'] as num?)?.toDouble() ?? 0.0;

        final score = (roomMap['score'] as num?)?.toDouble();
        final fromPreviousSeconds =
            (roomMap['from_previous_seconds'] as num?)?.toDouble();
        final toNextSeconds =
            (roomMap['to_next_seconds'] as num?)?.toDouble();

        final roomParts = roomId.split(' ');
        final buildingCode = roomParts.isNotEmpty ? roomParts.first : '';
        final roomNumber =
            roomParts.length > 1 ? roomParts.sublist(1).join(' ') : '';

        items.add(
          RoomSearchItem(
            roomId: roomId,
            buildingCode: buildingCode,
            buildingName: buildingName,
            roomNumber: roomNumber,
            capacity: capacity,
            reliability: reliability,
            utilities: [
              if (score != null) 'score ${score.toStringAsFixed(2)}',
              if (fromPreviousSeconds != null)
                'prev ${(fromPreviousSeconds / 60).round()} min',
              if (toNextSeconds != null)
                'next ${(toNextSeconds / 60).round()} min',
            ],
            distanceSeconds: toNextSeconds ?? fromPreviousSeconds,
            matchingWindows: [
              MatchingWindow(
                start: slotStart,
                end: slotEnd,
              ),
            ],
          ),
        );
      }
    }

    return items;
  }
}