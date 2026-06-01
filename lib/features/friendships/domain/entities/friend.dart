import '../../../auth/domain/entities/user_status.dart';

class Friend {
  const Friend({
    required this.email,
    required this.username,
    required this.status,
    this.shareSchedule = true,
    this.isPendingSync = false,
  });

  final String email;
  final String username;
  final UserStatus status;
  final bool shareSchedule;
  final bool isPendingSync;

  Friend copyWith({
    String? email,
    String? username,
    UserStatus? status,
    bool? shareSchedule,
    bool? isPendingSync,
  }) {
    return Friend(
      email: email ?? this.email,
      username: username ?? this.username,
      status: status ?? this.status,
      shareSchedule: shareSchedule ?? this.shareSchedule,
      isPendingSync: isPendingSync ?? this.isPendingSync,
    );
  }
}
