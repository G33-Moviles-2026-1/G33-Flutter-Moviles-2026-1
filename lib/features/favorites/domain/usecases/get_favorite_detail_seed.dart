import '../../../rooms/domain/entities/room_search.dart';
import '../entities/favorite_room.dart';
import '../repositories/favorites_repository.dart';

class GetFavoriteDetailSeed {
  const GetFavoriteDetailSeed(this._repository);

  final FavoritesRepository _repository;

  Future<RoomSearchItem> call(FavoriteRoom favorite) {
    return _repository.getFavoriteDetailSeed(favorite);
  }
}