import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../rooms/domain/entities/room_search.dart';
import '../../domain/entities/favorite_room.dart';
import '../../domain/usecases/get_cached_favorites.dart';
import '../../domain/usecases/get_favorite_detail_seed.dart';
import '../../domain/usecases/load_favorites.dart';
import '../../domain/usecases/remove_favorite.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../providers/favorites_providers.dart';
import 'favorites_state.dart';

class FavoritesNotifier extends Notifier<FavoritesState> {
  late final GetCachedFavorites _getCachedFavorites;
  late final LoadFavorites _loadFavorites;
  late final ToggleFavorite _toggleFavorite;
  late final RemoveFavorite _removeFavorite;
  late final GetFavoriteDetailSeed _getFavoriteDetailSeed;

  @override
  FavoritesState build() {
    _getCachedFavorites = ref.read(getCachedFavoritesUseCaseProvider);
    _loadFavorites = ref.read(loadFavoritesUseCaseProvider);
    _toggleFavorite = ref.read(toggleFavoriteUseCaseProvider);
    _removeFavorite = ref.read(removeFavoriteUseCaseProvider);
    _getFavoriteDetailSeed = ref.read(getFavoriteDetailSeedUseCaseProvider);

    Future.microtask(load);
    return const FavoritesState();
  }

  Future<void> load() async {
    final cached = await _getCachedFavorites();

    state = state.copyWith(
      items: cached.isNotEmpty ? cached : state.items,
      isLoading: true,
      clearErrorMessage: true,
    );

    try {
      final fresh = await _loadFavorites();
      state = state.copyWith(
        isLoading: false,
        items: fresh,
      );
    } catch (error) {
      if (cached.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  Future<void> toggleFromSearch(RoomSearchItem room) async {
    final wasFavorite = state.isFavorite(room.roomId);

    state = state.copyWith(
      pendingRoomIds: {...state.pendingRoomIds, room.roomId},
      clearErrorMessage: true,
      items: wasFavorite
          ? state.items.where((e) => e.roomId != room.roomId).toList()
          : [
              FavoriteRoom(
                roomId: room.roomId,
                buildingCode: room.buildingCode,
                buildingName: room.buildingName,
                roomNumber: room.roomNumber,
                capacity: room.capacity,
                reliability: room.reliability,
                utilities: room.utilities,
                isPendingSync: true,
              ),
              ...state.items,
            ],
    );

    try {
      await _toggleFavorite(room);
      final cached = await _getCachedFavorites();
      state = state.copyWith(
        items: cached,
        pendingRoomIds: {...state.pendingRoomIds}..remove(room.roomId),
      );
    } catch (error) {
      final cached = await _getCachedFavorites();
      state = state.copyWith(
        items: cached,
        pendingRoomIds: {...state.pendingRoomIds}..remove(room.roomId),
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> removeFromFavorites(FavoriteRoom room) async {
    state = state.copyWith(
      pendingRoomIds: {...state.pendingRoomIds, room.roomId},
      clearErrorMessage: true,
      items: state.items.where((e) => e.roomId != room.roomId).toList(),
    );

    try {
      await _removeFavorite(room.roomId);
      final cached = await _getCachedFavorites();
      state = state.copyWith(
        items: cached,
        pendingRoomIds: {...state.pendingRoomIds}..remove(room.roomId),
      );
    } catch (error) {
      final cached = await _getCachedFavorites();
      state = state.copyWith(
        items: cached,
        pendingRoomIds: {...state.pendingRoomIds}..remove(room.roomId),
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> undoRemoveFromFavorites(FavoriteRoom room) async {
    state = state.copyWith(
      pendingRoomIds: {...state.pendingRoomIds, room.roomId},
      clearErrorMessage: true,
      items: [room, ...state.items],
    );

    try {
      await _toggleFavorite(room.toRoomSearchItem());
      final cached = await _getCachedFavorites();
      state = state.copyWith(
        items: cached,
        pendingRoomIds: {...state.pendingRoomIds}..remove(room.roomId),
      );
    } catch (error) {
      final cached = await _getCachedFavorites();
      state = state.copyWith(
        items: cached,
        pendingRoomIds: {...state.pendingRoomIds}..remove(room.roomId),
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<RoomSearchItem> getDetailSeed(FavoriteRoom room) {
    return _getFavoriteDetailSeed(room);
  }
}