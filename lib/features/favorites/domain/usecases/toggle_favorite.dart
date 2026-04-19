import '../../../rooms/domain/entities/room_search.dart';
import '../repositories/favorites_repository.dart';

class ToggleFavorite {
  const ToggleFavorite(this._repository);

  final FavoritesRepository _repository;

  Future<bool> call(RoomSearchItem room) => _repository.toggleFavorite(room);
}