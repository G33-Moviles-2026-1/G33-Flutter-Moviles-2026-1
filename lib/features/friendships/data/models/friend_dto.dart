import 'package:andespace/core/local/app_database.dart';
import 'package:andespace/features/auth/domain/entities/user_status.dart';
import 'package:andespace/features/friendships/domain/entities/friend.dart';
import 'package:andespace/features/friendships/domain/entities/friendship_request.dart';
import 'package:drift/drift.dart';

class FriendDto {
  FriendDto({
    required this.email,
    required this.username,
    required this.status,
    this.shareSchedule = true,
    this.syncState = 'clean',
    this.lastError,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  final String email;
  final String username;
  final String status;
  final bool shareSchedule;
  final String syncState;
  final String? lastError;
  final DateTime updatedAt;

  factory FriendDto.fromJson(Map<String, dynamic> json) {
    return FriendDto(
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      status: json['status']?.toString() ?? 'incognito',
      shareSchedule: json['share_schedule'] as bool? ?? true,
    );
  }

  factory FriendDto.fromDb(FriendsTableData row) {
    return FriendDto(
      email: row.email,
      username: row.username,
      status: row.status,
      shareSchedule: true,
      syncState: row.syncState,
      lastError: row.lastError,
      updatedAt: row.updatedAt,
    );
  }

  FriendsTableCompanion toCompanion({
    String? syncStateOverride,
    String? lastErrorOverride,
  }) {
    return FriendsTableCompanion(
      email: Value(email),
      username: Value(username),
      status: Value(status),
      syncState: Value(syncStateOverride ?? syncState),
      lastError: Value(lastErrorOverride),
      updatedAt: Value(DateTime.now()),
    );
  }

  Friend toDomain() {
    return Friend(
      email: email,
      username: username,
      status: UserStatus.fromBackendKey(status),
      shareSchedule: shareSchedule,
      isPendingSync: syncState != 'clean',
    );
  }

  FriendshipRequest toRequest({required bool isIncoming}) {
    return FriendshipRequest(
      email: email,
      username: username,
      status: UserStatus.fromBackendKey(status),
      isIncoming: isIncoming,
    );
  }
}
