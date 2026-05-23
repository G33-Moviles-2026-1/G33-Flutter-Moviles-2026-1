import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:andespace/features/auth/domain/entities/user_status.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/friend.dart';
import '../../domain/entities/friendship_request.dart';
import '../../domain/repositories/friendships_repository.dart';
import '../local/friendships_local_datasource.dart';
import '../models/friend_dto.dart';
import '../models/friends_response_dto.dart';
import '../remote/friendships_api.dart';

class FriendshipsRepositoryImpl implements FriendshipsRepository {
  FriendshipsRepositoryImpl({
    required this.api,
    required this.localDataSource,
  });

  final FriendshipsApi api;
  final FriendshipsLocalDataSource localDataSource;

  @override
  Future<List<Friend>> getCachedFriends() async {
    final dtos = await localDataSource.getVisibleFriends();
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<List<Friend>> loadFriends() async {
    await syncPendingMutations();

    final raw = await api.fetchMyFriends();
    final response = FriendsResponseDto.fromJson(raw);

    await localDataSource.replaceCleanFriends(response.items);

    return getCachedFriends();
  }

  @override
  Future<List<FriendshipRequest>> loadIncomingRequests() async {
    final raw = await api.fetchIncomingRequests();
    final response = FriendsResponseDto.fromJson(raw);

    return response.items
        .map((dto) => dto.toRequest(isIncoming: true))
        .toList();
  }

  @override
  Future<List<FriendshipRequest>> loadOutgoingRequests() async {
    final raw = await api.fetchOutgoingRequests();
    final response = FriendsResponseDto.fromJson(raw);

    return response.items
        .map((dto) => dto.toRequest(isIncoming: false))
        .toList();
  }

  @override
  Future<List<String>> loadSuggestions() {
    return api.fetchSuggestions();
  }

  @override
  Future<void> sendFriendRequest(String username) {
    return api.sendFriendRequest(username);
  }

  @override
  Future<void> acceptFriendRequest(String username) {
    return api.acceptFriendRequest(username);
  }

  @override
  Future<void> declineOrCancelRequest(String username) {
    return api.deleteFriendship(username);
  }

  @override
  Future<void> removeFriend(Friend friend) async {
    final dto = FriendDto(
      email: friend.email,
      username: friend.username,
      status: friend.status.backendKey,
    );

    await localDataSource.markPendingRemove(dto);

    Future(() async {
      try {
        await syncPendingMutations();
      } catch (_) {
        // The pending mutation remains stored and will retry on recovery/manual refresh.
      }
    });
  }

  @override
  Future<UserStatus> getCachedMyStatus({
    UserStatus fallback = UserStatus.incognito,
  }) {
    return localDataSource.getMyStatus(fallback: fallback);
  }

  @override
  Future<void> updateMyStatus(UserStatus status) async {
    await localDataSource.updateMyStatusLocally(status);

    Future(() async {
      try {
        await syncPendingMutations();
      } catch (_) {
        // The pending mutation remains stored and will retry on recovery/manual refresh.
      }
    });
  }

  @override
  Future<void> syncPendingMutations() async {
    final pending = await localDataSource.getPendingMutations();

    for (final mutation in pending) {
      try {
        if (mutation.operation == 'delete_friend') {
          final identifier = mutation.identifier;

          if (identifier != null && identifier.trim().isNotEmpty) {
            try {
              await api.deleteFriendship(identifier);
            } on DioException catch (error) {
              // If backend no longer has the friendship, local pending removal is already valid.
              if (error.response?.statusCode != 404) rethrow;
            }

            await localDataSource.hardDeleteFriend(identifier);
          }

          await localDataSource.clearMutation(mutation.opId);
        } else if (mutation.operation == 'update_status') {
          final statusKey = mutation.status;

          if (statusKey != null && statusKey.trim().isNotEmpty) {
            final status = UserStatus.fromBackendKey(statusKey);
            await api.updateMyStatus(status.backendKey);
            await localDataSource.markMyStatusClean(status);
          }

          await localDataSource.clearMutation(mutation.opId);
        }
      } catch (error) {
        throw Exception(
          DioErrorMapper.map(
            error,
            fallback: 'Some friend changes could not be synced.',
          ),
        );
      }
    }
  }

  @override
  Future<void> clearLocalData() {
    return localDataSource.clearLocalData();
  }
}