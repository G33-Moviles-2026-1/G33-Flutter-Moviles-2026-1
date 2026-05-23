import 'package:andespace/core/local/app_database.dart';
import 'package:andespace/features/auth/domain/entities/user_status.dart';
import 'package:andespace/features/friendships/data/models/friend_dto.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class FriendshipsLocalDataSource {
  FriendshipsLocalDataSource(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  Future<List<FriendDto>> getVisibleFriends() async {
    final rows = await _db.getVisibleFriends();
    return rows.map(FriendDto.fromDb).toList();
  }

  Future<void> replaceCleanFriends(List<FriendDto> friends) async {
    await _db.replaceCleanFriends(
      friends
          .map(
            (friend) => friend.toCompanion(
              syncStateOverride: 'clean',
              lastErrorOverride: null,
            ),
          )
          .toList(),
    );

    await _db.deleteCleanFriendsNotIn(friends.map((f) => f.email).toSet());
  }

  Future<void> markPendingRemove(FriendDto friend) async {
    await _db.upsertFriend(
      friend.toCompanion(
        syncStateOverride: 'pending_remove',
        lastErrorOverride: null,
      ),
    );

    final now = DateTime.now();

    await _db.upsertFriendMutation(
      FriendMutationsTableCompanion(
        opId: Value(_uuid.v4()),
        operation: const Value('delete_friend'),
        identifier: Value(friend.username),
        status: const Value(null),
        attemptCount: const Value(0),
        lastError: const Value(null),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<UserStatus> getMyStatus({UserStatus fallback = UserStatus.incognito}) async {
    final row = await _db.getMyStatusRow();
    if (row == null) return fallback;
    return UserStatus.fromBackendKey(row.status);
  }

  Future<void> updateMyStatusLocally(UserStatus status) async {
    final now = DateTime.now();

    await _db.upsertMyStatus(
      MyStatusTableCompanion(
        id: const Value('me'),
        status: Value(status.backendKey),
        syncState: const Value('pending_update'),
        updatedAt: Value(now),
      ),
    );

    await _db.deleteStatusUpdateMutations();

    await _db.upsertFriendMutation(
      FriendMutationsTableCompanion(
        opId: const Value('my_status_update'),
        operation: const Value('update_status'),
        identifier: const Value(null),
        status: Value(status.backendKey),
        attemptCount: const Value(0),
        lastError: const Value(null),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> markMyStatusClean(UserStatus status) async {
    await _db.upsertMyStatus(
      MyStatusTableCompanion(
        id: const Value('me'),
        status: Value(status.backendKey),
        syncState: const Value('clean'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<FriendMutationsTableData>> getPendingMutations() {
    return _db.getPendingFriendMutations();
  }

  Future<void> clearMutation(String opId) {
    return _db.deleteFriendMutationById(opId);
  }

  Future<void> hardDeleteFriend(String email) {
    return _db.deleteFriendByEmail(email);
  }
}