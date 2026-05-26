import 'package:dio/dio.dart';

import '../../../../core/error/dio_error_mapper.dart';
import '../../../rooms/domain/entities/room_search.dart';
import '../../domain/entities/favorite_room.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../local/favorites_local_datasource.dart';
import '../models/favorite_room_snapshot_dto.dart';
import '../models/my_favorites_response_dto.dart';
import '../remote/favorites_api.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl({
    required this.favoritesApi,
    required this.localDataSource,
    required this.dio,
  });

  final FavoritesApi favoritesApi;
  final FavoritesLocalDataSource localDataSource;
  final Dio dio;

  @override
  Future<List<FavoriteRoom>> getCachedFavorites() async {
    final dtos = await localDataSource.getVisibleFavorites();
    return dtos.map((e) => e.toDomain()).toList();
  }

  @override
  Future<List<FavoriteRoom>> loadFavorites() async {
    await _syncPendingMutations();

    final raw = await favoritesApi.fetchMyFavorites();
    final response = MyFavoritesResponseDto.fromJson(raw);
    final serverIds = response.roomIds.toSet();

    final local = await localDataSource.getAllFavorites();
    final localById = {for (final item in local) item.roomId: item};

    for (final roomId in serverIds) {
      final existing = localById[roomId];
      if (existing != null) {
        await localDataSource.upsertCleanFavorite(existing);
        continue;
      }

      final hydrated = await _hydrateSnapshot(roomId);
      await localDataSource.upsertCleanFavorite(hydrated);
    }

    await localDataSource.deleteCleanFavoritesNotIn(serverIds);

    return getCachedFavorites();
  }

  @override
  Future<bool> isFavorite(String roomId) => localDataSource.isFavorite(roomId);

  @override
  Future<bool> toggleFavorite(RoomSearchItem room) async {
    final current = await localDataSource.isFavorite(room.roomId);

    if (current) {
      await localDataSource.markPendingRemove(room.roomId);
      Future(() async {
        try {
          await _syncPendingMutations();
        } catch (_) {}
      });
      return false;
    }

    final dto = FavoriteRoomSnapshotDto.fromRoomSearchItem(room);
    await localDataSource.markPendingAdd(dto);

    Future(() async {
      try {
        await _syncPendingMutations();
      } catch (_) {}
    });

    return true;
  }

  @override
  Future<void> removeFavorite(String roomId) async {
    await localDataSource.markPendingRemove(roomId);
    Future(() async {
      try {
        await _syncPendingMutations();
      } catch (_) {}
    });
  }

  @override
  Future<RoomSearchItem> getFavoriteDetailSeed(FavoriteRoom favorite) async {
    try {
      final hydrated = await _hydrateSnapshot(favorite.roomId);
      await localDataSource.upsertCleanFavorite(hydrated);

      return hydrated.toDomain().toRoomSearchItem();
    } catch (error) {
      throw Exception(
        DioErrorMapper.map(
          error,
          fallback:
              'No internet connection. Please check your connection to open room details.',
          onBadResponse: (statusCode, detail) {
            if (detail != null) return detail;
            return 'No internet connection. Please check your connection to open room details.';
          },
        ),
      );
    }
  }

  @override
  Future<void> clearLocalData() async {
    await localDataSource.clear();
  }

  Future<void> _syncPendingMutations() async {
    final pending = await localDataSource.getPendingMutations();

    for (final mutation in pending) {
      try {
        if (mutation.operation == 'add') {
          await favoritesApi.createFavorite(mutation.roomId);

          final local = await localDataSource.getFavoriteById(mutation.roomId);
          if (local != null) {
            await localDataSource.upsertCleanFavorite(local);
          }

          await localDataSource.clearMutation(mutation.opId);
        } else {
          try {
            await favoritesApi.deleteFavorite(mutation.roomId);
          } on DioException catch (error) {
            final status = error.response?.statusCode;
            if (status != 404) rethrow;
          }

          await localDataSource.hardDeleteFavorite(mutation.roomId);
          await localDataSource.clearMutation(mutation.opId);
        }
      } catch (error) {
        await localDataSource.markMutationFailed(
          mutation.opId,
          DioErrorMapper.map(error),
        );
        rethrow;
      }
    }
  }

  Future<FavoriteRoomSnapshotDto> _hydrateSnapshot(String roomId) async {
    final today = _todayApi();
    final response = await dio.get(
      '/rooms/${Uri.encodeComponent(roomId)}/availability',
      queryParameters: {'date_value': today},
    );

    final json = Map<String, dynamic>.from(response.data as Map);

    final parsedRoomId = (json['room_id'] as String?) ?? roomId;
    final parsedBuildingCode =
        (json['building_code'] as String?) ?? _inferBuildingCode(roomId);
    final parsedRoomNumber =
        (json['room_number'] as String?) ?? _inferRoomNumber(roomId);

    final utilitiesRaw = (json['utilities'] as List<dynamic>? ?? const []);
    final utilities = utilitiesRaw.map((e) => e.toString()).toList();

    return FavoriteRoomSnapshotDto(
      roomId: parsedRoomId,
      buildingCode: parsedBuildingCode,
      buildingName: json['building_name'] as String?,
      roomNumber: parsedRoomNumber,
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      reliability: (json['reliability'] as num?)?.toDouble() ?? 0,
      utilities: utilities,
      syncState: 'clean',
      savedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastError: null,
    );
  }

  String _todayApi() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _inferBuildingCode(String roomId) {
    final parts = roomId.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : roomId;
  }

  String _inferRoomNumber(String roomId) {
    final parts = roomId.trim().split(RegExp(r'\s+'));
    return parts.length > 1 ? parts.sublist(1).join(' ') : roomId;
  }
}