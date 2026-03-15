import '../../domain/entities/room_date_availability.dart';

class RoomDateSlotDto {
  const RoomDateSlotDto({
    required this.start,
    required this.end,
    required this.isAvailable,
  });

  final String start;
  final String end;
  final bool isAvailable;

  factory RoomDateSlotDto.fromJson(Map<String, dynamic> json) {
    return RoomDateSlotDto(
      start: json['start'] as String,
      end: json['end'] as String,
      isAvailable: json['is_available'] as bool? ?? false,
    );
  }

  RoomDateSlot toDomain() => RoomDateSlot(
        start: start,
        end: end,
        isAvailable: isAvailable,
      );
}

class RoomDateAvailabilityDto {
  const RoomDateAvailabilityDto({
    required this.roomId,
    required this.date,
    required this.availableSlots,
    required this.blockedSlots,
  });

  final String roomId;
  final String date;
  final List<RoomDateSlotDto> availableSlots;
  final List<RoomDateSlotDto> blockedSlots;

  factory RoomDateAvailabilityDto.fromJson(Map<String, dynamic> json) {
    return RoomDateAvailabilityDto(
      roomId: json['room_id'] as String,
      date: json['date'] as String,
      availableSlots: (json['available_slots'] as List<dynamic>? ?? const [])
          .map((e) => RoomDateSlotDto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      blockedSlots: (json['blocked_slots'] as List<dynamic>? ?? const [])
          .map((e) => RoomDateSlotDto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  RoomDateAvailability toDomain() => RoomDateAvailability(
        roomId: roomId,
        date: date,
        availableSlots: availableSlots.map((e) => e.toDomain()).toList(),
        blockedSlots: blockedSlots.map((e) => e.toDomain()).toList(),
      );
}