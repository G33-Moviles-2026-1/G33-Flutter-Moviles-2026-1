import '../../../rooms/domain/entities/room_search.dart';
import '../entities/favorite_room.dart';

abstract class FavoritesRepository {
  Future<List<FavoriteRoom>> getCachedFavorites();

  Future<List<FavoriteRoom>> loadFavorites();

  Future<bool> isFavorite(String roomId);

  Future<bool> toggleFavorite(RoomSearchItem room);

  Future<void> removeFavorite(String roomId);

  Future<RoomSearchItem> getFavoriteDetailSeed(FavoriteRoom favorite);

  Future<void> clearLocalData();
}