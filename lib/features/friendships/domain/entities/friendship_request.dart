import '../../../auth/domain/entities/user_status.dart';

class FriendshipRequest {
  const FriendshipRequest({
    required this.email,
    required this.username,
    required this.status,
    required this.isIncoming,
  });

  final String email;
  final String username;
  final UserStatus status;
  final bool isIncoming;
}