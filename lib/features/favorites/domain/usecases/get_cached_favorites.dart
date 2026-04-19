import '../entities/favorite_room.dart';
import '../repositories/favorites_repository.dart';

class GetCachedFavorites {
  const GetCachedFavorites(this._repository);

  final FavoritesRepository _repository;

  Future<List<FavoriteRoom>> call() => _repository.getCachedFavorites();
}