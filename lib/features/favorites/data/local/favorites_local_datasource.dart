import 'package:andespace/core/local/app_database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/local/app_database.dart';
import '../models/favorite_mutation_dto.dart';
import '../models/favorite_room_snapshot_dto.dart';

class FavoritesLocalDataSource {
  FavoritesLocalDataSource(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  Future<List<FavoriteRoomSnapshotDto>> getVisibleFavorites() async {
    final rows = await _db.getVisibleFavorites();
    return rows.map(FavoriteRoomSnapshotDto.fromDb).toList();
  }

  Future<List<FavoriteRoomSnapshotDto>> getAllFavorites() async {
    final rows = await _db.getAllFavorites();
    return rows.map(FavoriteRoomSnapshotDto.fromDb).toList();
  }

  Future<FavoriteRoomSnapshotDto?> getFavoriteById(String roomId) async {
    final row = await _db.getFavoriteById(roomId);
    if (row == null) return null;
    return FavoriteRoomSnapshotDto.fromDb(row);
  }

  Future<bool> isFavorite(String roomId) async {
    final row = await _db.getFavoriteById(roomId);
    return row != null && row.syncState != 'pending_remove';
  }

  Future<void> upsertCleanFavorite(FavoriteRoomSnapshotDto dto) async {
    await _db.upsertFavorite(
      dto.toCompanion(syncStateOverride: 'clean', lastErrorOverride: null),
    );
  }

  Future<void> markPendingAdd(FavoriteRoomSnapshotDto dto) async {
    final existingMutations = await _db.getFavoriteMutationsForRoom(dto.roomId);

    for (final mutation in existingMutations) {
      if (mutation.operation == 'remove') {
        await _db.deleteFavoriteMutationById(mutation.opId);
      }
    }

    await _db.upsertFavorite(
      dto.toCompanion(
        syncStateOverride: 'pending_add',
        lastErrorOverride: null,
      ),
    );

    final remaining = await _db.getFavoriteMutationsForRoom(dto.roomId);
    final hasAdd = remaining.any((m) => m.operation == 'add');

    if (!hasAdd) {
      final now = DateTime.now();
      await _db.upsertFavoriteMutation(
        FavoriteMutationDto(
          opId: _uuid.v4(),
          roomId: dto.roomId,
          operation: 'add',
          attemptCount: 0,
          lastError: null,
          createdAt: now,
          updatedAt: now,
        ).toCompanion(),
      );
    }
  }

  Future<void> markPendingRemove(String roomId) async {
    final existingRow = await _db.getFavoriteById(roomId);
    if (existingRow == null) return;

    final existingMutations = await _db.getFavoriteMutationsForRoom(roomId);
    final hasPendingAdd = existingMutations.any((m) => m.operation == 'add');

    if (existingRow.syncState == 'pending_add' && hasPendingAdd) {
      await _db.deleteFavoriteMutationsForRoom(roomId);
      await _db.deleteFavoriteById(roomId);
      return;
    }

    await _db.upsertFavorite(
      FavoriteRoomsTableCompanion(
        roomId: Value(existingRow.roomId),
        buildingCode: Value(existingRow.buildingCode),
        buildingName: Value(existingRow.buildingName),
        roomNumber: Value(existingRow.roomNumber),
        capacity: Value(existingRow.capacity),
        reliability: Value(existingRow.reliability),
        utilitiesJson: Value(existingRow.utilitiesJson),
        syncState: const Value('pending_remove'),
        lastError: const Value(null),
        savedAt: Value(existingRow.savedAt),
        updatedAt: Value(DateTime.now()),
      ),
    );

    final refreshedMutations = await _db.getFavoriteMutationsForRoom(roomId);
    final hasRemove = refreshedMutations.any((m) => m.operation == 'remove');

    if (!hasRemove) {
      final now = DateTime.now();
      await _db.upsertFavoriteMutation(
        FavoriteMutationDto(
          opId: _uuid.v4(),
          roomId: roomId,
          operation: 'remove',
          attemptCount: 0,
          lastError: null,
          createdAt: now,
          updatedAt: now,
        ).toCompanion(),
      );
    }
  }

  Future<List<FavoriteMutationDto>> getPendingMutations() async {
    final rows = await _db.getPendingFavoriteMutations();
    return rows.map(FavoriteMutationDto.fromDb).toList();
  }

  Future<void> markMutationFailed(String opId, String message) async {
    final pending = await _db.getPendingFavoriteMutations();
    final row = pending.where((e) => e.opId == opId).firstOrNull;
    if (row == null) return;

    await _db.upsertFavoriteMutation(
      FavoriteMutationsTableCompanion(
        opId: Value(row.opId),
        roomId: Value(row.roomId),
        operation: Value(row.operation),
        attemptCount: Value(row.attemptCount + 1),
        lastError: Value(message),
        createdAt: Value(row.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> clearMutation(String opId) =>
      _db.deleteFavoriteMutationById(opId);

  Future<void> hardDeleteFavorite(String roomId) async {
    await _db.deleteFavoriteMutationsForRoom(roomId);
    await _db.deleteFavoriteById(roomId);
  }

  Future<void> deleteCleanFavoritesNotIn(Set<String> roomIds) =>
      _db.deleteCleanFavoritesNotIn(roomIds);

  Future<void> clear() => _db.delete(_db.favoriteRoomsTable).go();
}
