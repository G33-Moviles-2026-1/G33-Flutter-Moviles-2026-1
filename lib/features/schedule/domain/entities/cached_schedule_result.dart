import 'friends_free_slot.dart';
import 'weekly_schedule.dart';

class FriendWeeklyScheduleResult {
  const FriendWeeklyScheduleResult({
    required this.schedule,
    required this.isOffline,
    this.lastUpdated,
  });

  final WeeklySchedule schedule;
  final bool isOffline;
  final DateTime? lastUpdated;
}

class FriendsFreeSlotsResult {
  const FriendsFreeSlotsResult({
    required this.freeSlots,
    required this.isOffline,
    this.lastUpdated,
  });

  final FriendsFreeSlots freeSlots;
  final bool isOffline;
  final DateTime? lastUpdated;
}
