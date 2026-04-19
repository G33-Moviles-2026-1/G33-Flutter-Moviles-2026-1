import '../repositories/favorites_repository.dart';

class RemoveFavorite {
  const RemoveFavorite(this._repository);

  final FavoritesRepository _repository;

  Future<void> call(String roomId) => _repository.removeFavorite(roomId);
}