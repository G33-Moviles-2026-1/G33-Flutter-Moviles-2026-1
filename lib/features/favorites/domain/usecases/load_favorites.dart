import '../../../../core/error/dio_error_mapper.dart';
import '../entities/favorite_room.dart';
import '../repositories/favorites_repository.dart';

class LoadFavorites {
  const LoadFavorites(this._repository);

  final FavoritesRepository _repository;

  Future<List<FavoriteRoom>> call() async {
    try {
      return await _repository.loadFavorites();
    } catch (error) {
      throw Exception(
        DioErrorMapper.map(
          error,
          onBadResponse: (statusCode, detail) {
            if (detail != null) return detail;
            if (statusCode >= 400) {
              return 'We could not load your favorite rooms. Please try again.';
            }
            return 'Something went wrong. Please try again.';
          },
        ),
      );
    }
  }
}