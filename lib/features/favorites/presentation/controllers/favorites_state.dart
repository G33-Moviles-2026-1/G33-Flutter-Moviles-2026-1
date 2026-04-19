import '../../domain/entities/favorite_room.dart';

class FavoritesState {
  const FavoritesState({
    this.isLoading = false,
    this.items = const [],
    this.pendingRoomIds = const {},
    this.errorMessage,
  });

  final bool isLoading;
  final List<FavoriteRoom> items;
  final Set<String> pendingRoomIds;
  final String? errorMessage;

  bool isFavorite(String roomId) => items.any((item) => item.roomId == roomId);

  FavoritesState copyWith({
    bool? isLoading,
    List<FavoriteRoom>? items,
    Set<String>? pendingRoomIds,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return FavoritesState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      pendingRoomIds: pendingRoomIds ?? this.pendingRoomIds,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}