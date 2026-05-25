import 'dart:math';

import 'package:andespace/features/friendships/domain/entities/friend.dart';
import 'package:andespace/features/schedule/domain/entities/friends_free_slot.dart';
import 'package:andespace/features/schedule/domain/repositories/schedule_repository.dart';

class LoadFriendsFreeSlotsForWeekUseCase {
  const LoadFriendsFreeSlotsForWeekUseCase({required this.scheduleRepository});

  final ScheduleRepository scheduleRepository;

  Future<FriendsFreeSlots> call({
    required List<Friend> friends,
    required DateTime referenceDate,
  }) async {
    final friendEmails = friends.map((friend) => friend.email).toList();
    final days = await Future.wait(
      buildWeekDays(referenceDate).map(
        (day) => scheduleRepository.getFriendsFreeSlots(
          friendEmails: friendEmails,
          date: day,
        ),
      ),
    );

    return FriendsFreeSlots(
      totalFriends: days.fold<int>(
        friends.length,
        (maxCount, day) => max(maxCount, day.totalFriends),
      ),
      slots: days.expand((day) => day.slots).toList(),
    );
  }

  static List<DateTime> buildWeekDays(DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));

    return List<DateTime>.generate(6, (index) {
      final day = weekStart.add(Duration(days: index));
      return DateTime(day.year, day.month, day.day);
    });
  }
}
