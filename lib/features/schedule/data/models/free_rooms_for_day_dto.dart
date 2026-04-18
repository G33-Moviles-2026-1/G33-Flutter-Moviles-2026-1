class FreeSlotModel {
  final String startTime;
  final String endTime;

  const FreeSlotModel({
    required this.startTime,
    required this.endTime,
  });

  factory FreeSlotModel.fromJson(Map<String, dynamic> json) {
    return FreeSlotModel(
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
    );
  }
}

class RoomInSlotModel {
  final String roomId;
  final String? buildingName;
  final int capacity;
  final double reliability;

  const RoomInSlotModel({
    required this.roomId,
    this.buildingName,
    required this.capacity,
    required this.reliability,
  });

  factory RoomInSlotModel.fromJson(Map<String, dynamic> json) {
    return RoomInSlotModel(
      roomId: json['room_id']?.toString() ?? '',
      buildingName: json['building_name'] as String?,
      capacity: json['capacity'] as int? ?? 0,
      reliability: (json['reliability'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SlotWithRoomsModel {
  final String slotStart;
  final String slotEnd;
  final List<RoomInSlotModel> availableRooms;

  const SlotWithRoomsModel({
    required this.slotStart,
    required this.slotEnd,
    required this.availableRooms,
  });

  factory SlotWithRoomsModel.fromJson(Map<String, dynamic> json) {
    return SlotWithRoomsModel(
      slotStart: json['slot_start']?.toString() ?? '',
      slotEnd: json['slot_end']?.toString() ?? '',
      availableRooms: (json['available_rooms'] as List<dynamic>? ?? [])
          .map((e) => RoomInSlotModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FreeRoomsForDayModel {
  final DateTime date;
  final String weekday;
  final List<FreeSlotModel> freeSlots;
  final List<SlotWithRoomsModel> slotsWithRooms;

  const FreeRoomsForDayModel({
    required this.date,
    required this.weekday,
    required this.freeSlots,
    required this.slotsWithRooms,
  });

  factory FreeRoomsForDayModel.fromJson(Map<String, dynamic> json) {
    return FreeRoomsForDayModel(
      date: DateTime.parse(json['date'] as String),
      weekday: json['weekday'] as String? ?? '',
      freeSlots: (json['free_slots'] as List<dynamic>? ?? [])
          .map((e) => FreeSlotModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      slotsWithRooms: (json['slots_with_rooms'] as List<dynamic>? ?? [])
          .map((e) => SlotWithRoomsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
