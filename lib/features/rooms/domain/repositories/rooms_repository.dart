import '../entities/room_date_availability.dart';
import '../entities/room_recommendation.dart';
import '../entities/room_search.dart';

abstract class RoomRepository {
  Future<RoomSearchResponse> searchRooms(RoomSearchRequest request);

  Future<List<RoomSearchItem>> autoSearchRooms(AutoSearchRoomsRequest request);

  Future<void> submitRecommendationInteraction(
    RoomRecommendationInteraction interaction,
  );

  Future<RoomDateAvailability> fetchRoomDateAvailability({
    required String roomId,
    required String date,
  });

  RoomSearchResponse? getCachedSearchPage(int pageNumber);

  void cacheFirstSearchPage({
    required RoomSearchRequest baseQuery,
    required RoomSearchResponse firstPage,
  });

  Future<void> prefetchFirstPages(RoomSearchRequest baseQuery);
}
