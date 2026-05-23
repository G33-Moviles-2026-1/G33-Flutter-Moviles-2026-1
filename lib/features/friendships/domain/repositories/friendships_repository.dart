import '../../../auth/domain/entities/user_status.dart';
import '../entities/friend.dart';
import '../entities/friendship_request.dart';

abstract class FriendshipsRepository {
  Future<List<Friend>> getCachedFriends();

  Future<List<Friend>> loadFriends();

  Future<List<FriendshipRequest>> loadIncomingRequests();

  Future<List<FriendshipRequest>> loadOutgoingRequests();

  Future<List<String>> loadSuggestions();

  Future<void> sendFriendRequest(String username);

  Future<void> acceptFriendRequest(String username);

  Future<void> declineOrCancelRequest(String username);

  Future<void> removeFriend(Friend friend);

  Future<UserStatus> getCachedMyStatus({UserStatus fallback});

  Future<void> updateMyStatus(UserStatus status);

  Future<void> syncPendingMutations();

  Future<void> clearLocalData();

  Future<void> ensureLocalCacheForUser(String userEmail);
}