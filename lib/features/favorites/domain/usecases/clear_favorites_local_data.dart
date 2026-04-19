import '../repositories/favorites_repository.dart';

class ClearFavoritesLocalData {
  const ClearFavoritesLocalData(this._repository);

  final FavoritesRepository _repository;

  Future<void> call() => _repository.clearLocalData();
}