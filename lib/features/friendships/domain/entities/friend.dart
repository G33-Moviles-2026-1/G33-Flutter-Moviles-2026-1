import '../../../auth/domain/entities/user_status.dart';

class Friend {
  const Friend({
    required this.email,
    required this.username,
    required this.status,
    this.isPendingSync = false,
  });

  final String email;
  final String username;
  final UserStatus status;
  final bool isPendingSync;

  Friend copyWith({
    String? email,
    String? username,
    UserStatus? status,
    bool? isPendingSync,
  }) {
    return Friend(
      email: email ?? this.email,
      username: username ?? this.username,
      status: status ?? this.status,
      isPendingSync: isPendingSync ?? this.isPendingSync,
    );
  }
}