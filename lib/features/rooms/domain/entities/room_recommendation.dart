class AutoSearchRoomsRequest {
  const AutoSearchRoomsRequest({
    required this.targetDate,
    required this.targetTime,
    this.topK = 3,
    this.excludeIds = const [],
  });

  final String targetDate;
  final String targetTime;
  final int topK;
  final List<String> excludeIds;
}

enum RoomRecommendationAction {
  skip('SKIP'),
  book('BOOK'),
  favorite('FAVORITE');

  const RoomRecommendationAction(this.apiValue);

  final String apiValue;
}

class RoomRecommendationInteraction {
  const RoomRecommendationInteraction({
    required this.roomId,
    required this.action,
    required this.weekday,
    required this.slotStart,
  });

  final String roomId;
  final RoomRecommendationAction action;
  final String weekday;
  final String slotStart;
}
