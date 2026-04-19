import 'package:drift/drift.dart';

import '../../../bookings/data/local/bookings_database.dart';

class FavoriteMutationDto {
  const FavoriteMutationDto({
    required this.opId,
    required this.roomId,
    required this.operation,
    required this.attemptCount,
    required this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });

  final String opId;
  final String roomId;
  final String operation; // add | remove
  final int attemptCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory FavoriteMutationDto.fromDb(FavoriteMutationsTableData row) {
    return FavoriteMutationDto(
      opId: row.opId,
      roomId: row.roomId,
      operation: row.operation,
      attemptCount: row.attemptCount,
      lastError: row.lastError,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  FavoriteMutationsTableCompanion toCompanion() {
    return FavoriteMutationsTableCompanion.insert(
      opId: opId,
      roomId: roomId,
      operation: operation,
      attemptCount: Value(attemptCount),
      lastError: Value(lastError),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}