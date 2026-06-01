import 'package:andespace/features/friendships/domain/entities/friend.dart';
import 'package:andespace/features/schedule/domain/entities/cached_schedule_result.dart';
import 'package:andespace/features/schedule/domain/repositories/schedule_repository.dart';

class LoadFriendScheduleUseCase {
  const LoadFriendScheduleUseCase({required this.scheduleRepository});

  final ScheduleRepository scheduleRepository;

  Future<FriendWeeklyScheduleResult> call({
    required Friend friend,
    required DateTime referenceDate,
  }) {
    return scheduleRepository.getFriendWeeklySchedule(
      friendEmail: friend.email,
      date: referenceDate,
    );
  }
}
