import 'package:andespace/features/rooms/domain/entities/room_search.dart';

class FriendsFreeSlotsRoomRecommendations {
  const FriendsFreeSlotsRoomRecommendations({
    required this.rooms,
    required this.timeFilterOptions,
    required this.description,
  });

  final List<RoomSearchItem> rooms;
  final List<MatchingWindow> timeFilterOptions;
  final String description;
}
