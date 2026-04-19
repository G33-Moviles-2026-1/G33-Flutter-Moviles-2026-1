import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_provider.dart';
import '../../data/local/favorites_local_datasource.dart';
import '../../data/remote/favorites_api.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/usecases/clear_favorites_local_data.dart';
import '../../domain/usecases/get_cached_favorites.dart';
import '../../domain/usecases/get_favorite_detail_seed.dart';
import '../../domain/usecases/load_favorites.dart';
import '../../domain/usecases/remove_favorite.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../controllers/favorites_notifier.dart';
import '../controllers/favorites_state.dart';

final favoritesLocalDataSourceProvider = Provider<FavoritesLocalDataSource>((ref) {
  throw UnimplementedError(
    'favoritesLocalDataSourceProvider must be overridden in main.dart',
  );
});

final favoritesApiProvider = Provider<FavoritesApi>((ref) {
  return FavoritesApi(ref.watch(dioProvider));
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepositoryImpl(
    favoritesApi: ref.watch(favoritesApiProvider),
    localDataSource: ref.watch(favoritesLocalDataSourceProvider),
    dio: ref.watch(dioProvider),
  );
});

final getCachedFavoritesUseCaseProvider = Provider<GetCachedFavorites>((ref) {
  return GetCachedFavorites(ref.watch(favoritesRepositoryProvider));
});

final loadFavoritesUseCaseProvider = Provider<LoadFavorites>((ref) {
  return LoadFavorites(ref.watch(favoritesRepositoryProvider));
});

final toggleFavoriteUseCaseProvider = Provider<ToggleFavorite>((ref) {
  return ToggleFavorite(ref.watch(favoritesRepositoryProvider));
});

final removeFavoriteUseCaseProvider = Provider<RemoveFavorite>((ref) {
  return RemoveFavorite(ref.watch(favoritesRepositoryProvider));
});

final getFavoriteDetailSeedUseCaseProvider =
    Provider<GetFavoriteDetailSeed>((ref) {
  return GetFavoriteDetailSeed(ref.watch(favoritesRepositoryProvider));
});

final clearFavoritesLocalDataUseCaseProvider =
    Provider<ClearFavoritesLocalData>((ref) {
  return ClearFavoritesLocalData(ref.watch(favoritesRepositoryProvider));
});

final favoritesControllerProvider =
    NotifierProvider<FavoritesNotifier, FavoritesState>(
  FavoritesNotifier.new,
);