import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../bookings/data/local/bookings_database.dart';
import '../../../rooms/domain/entities/room_search.dart';
import '../../domain/entities/favorite_room.dart';

class FavoriteRoomSnapshotDto {
  const FavoriteRoomSnapshotDto({
    required this.roomId,
    required this.buildingCode,
    required this.buildingName,
    required this.roomNumber,
    required this.capacity,
    required this.reliability,
    required this.utilities,
    required this.syncState,
    required this.savedAt,
    required this.updatedAt,
    required this.lastError,
  });

  final String roomId;
  final String buildingCode;
  final String? buildingName;
  final String roomNumber;
  final int capacity;
  final double reliability;
  final List<String> utilities;
  final String syncState;
  final DateTime savedAt;
  final DateTime updatedAt;
  final String? lastError;

  factory FavoriteRoomSnapshotDto.fromRoomSearchItem(RoomSearchItem room) {
    final now = DateTime.now();
    return FavoriteRoomSnapshotDto(
      roomId: room.roomId,
      buildingCode: room.buildingCode,
      buildingName: room.buildingName,
      roomNumber: room.roomNumber,
      capacity: room.capacity,
      reliability: room.reliability,
      utilities: room.utilities,
      syncState: 'clean',
      savedAt: now,
      updatedAt: now,
      lastError: null,
    );
  }

  factory FavoriteRoomSnapshotDto.fromDb(FavoriteRoomsTableData row) {
    return FavoriteRoomSnapshotDto(
      roomId: row.roomId,
      buildingCode: row.buildingCode,
      buildingName: row.buildingName,
      roomNumber: row.roomNumber,
      capacity: row.capacity,
      reliability: row.reliability,
      utilities: List<String>.from(jsonDecode(row.utilitiesJson) as List<dynamic>),
      syncState: row.syncState,
      savedAt: row.savedAt,
      updatedAt: row.updatedAt,
      lastError: row.lastError,
    );
  }

  FavoriteRoomsTableCompanion toCompanion({
    String? syncStateOverride,
    String? lastErrorOverride,
  }) {
    return FavoriteRoomsTableCompanion.insert(
      roomId: roomId,
      buildingCode: buildingCode,
      buildingName: Value(buildingName),
      roomNumber: roomNumber,
      capacity: capacity,
      reliability: reliability,
      utilitiesJson: Value(jsonEncode(utilities)),
      syncState: Value(syncStateOverride ?? syncState),
      lastError: Value(lastErrorOverride ?? lastError),
      savedAt: savedAt,
      updatedAt: DateTime.now(),
    );
  }

  FavoriteRoom toDomain() => FavoriteRoom(
        roomId: roomId,
        buildingCode: buildingCode,
        buildingName: buildingName,
        roomNumber: roomNumber,
        capacity: capacity,
        reliability: reliability,
        utilities: utilities,
        isPendingSync: syncState != 'clean',
      );
}