class FriendFreeSlot {
  const FriendFreeSlot({
    required this.startTime,
    required this.endTime,
    required this.freeCount,
    this.date,
    this.weekday,
    this.availableFriends = const [],
  });

  final DateTime? date;
  final String? weekday;
  final String startTime;
  final String endTime;
  final int freeCount;
  final List<String> availableFriends;
}

class FriendsFreeSlots {
  const FriendsFreeSlots({required this.totalFriends, required this.slots});

  final int totalFriends;
  final List<FriendFreeSlot> slots;
}
