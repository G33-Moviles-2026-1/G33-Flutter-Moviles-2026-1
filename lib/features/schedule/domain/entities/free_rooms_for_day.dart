class FreeSlot {
  final String startTime;
  final String endTime;

  const FreeSlot({
    required this.startTime,
    required this.endTime,
  });
}

class RoomInSlot {
  final String roomId;
  final String? buildingName;
  final int capacity;
  final double reliability;

  const RoomInSlot({
    required this.roomId,
    this.buildingName,
    required this.capacity,
    required this.reliability,
  });
}

class SlotWithRooms {
  final String slotStart;
  final String slotEnd;
  final List<RoomInSlot> availableRooms;

  const SlotWithRooms({
    required this.slotStart,
    required this.slotEnd,
    required this.availableRooms,
  });
}

class FreeRoomsForDay {
  final DateTime date;
  final String weekday;
  final List<FreeSlot> freeSlots;
  final List<SlotWithRooms> slotsWithRooms;

  const FreeRoomsForDay({
    required this.date,
    required this.weekday,
    required this.freeSlots,
    required this.slotsWithRooms,
  });
}