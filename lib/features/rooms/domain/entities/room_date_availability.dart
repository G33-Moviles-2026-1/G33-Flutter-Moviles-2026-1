class RoomDateSlot {
  const RoomDateSlot({
    required this.start,
    required this.end,
    required this.isAvailable,
  });

  final String start;
  final String end;
  final bool isAvailable;
}

class RoomDateAvailability {
  const RoomDateAvailability({
    required this.roomId,
    required this.date,
    required this.availableSlots,
    required this.blockedSlots,
  });

  final String roomId;
  final String date;
  final List<RoomDateSlot> availableSlots;
  final List<RoomDateSlot> blockedSlots;
}