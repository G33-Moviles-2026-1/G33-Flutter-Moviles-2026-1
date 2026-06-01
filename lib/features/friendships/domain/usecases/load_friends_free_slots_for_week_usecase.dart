import 'dart:math';

import 'package:andespace/features/friendships/domain/entities/friend.dart';
import 'package:andespace/features/schedule/domain/entities/cached_schedule_result.dart';
import 'package:andespace/features/schedule/domain/entities/friends_free_slot.dart';
import 'package:andespace/features/schedule/domain/repositories/schedule_repository.dart';

class FriendsFreeSlotsWeekResult {
  const FriendsFreeSlotsWeekResult({
    required this.freeSlots,
    required this.isOffline,
    this.lastUpdated,
  });

  final FriendsFreeSlots freeSlots;
  final bool isOffline;
  final DateTime? lastUpdated;
}

class LoadFriendsFreeSlotsForWeekUseCase {
  const LoadFriendsFreeSlotsForWeekUseCase({required this.scheduleRepository});

  final ScheduleRepository scheduleRepository;

  Future<FriendsFreeSlotsWeekResult> call({
    required List<Friend> friends,
    required DateTime referenceDate,
  }) async {
    final friendEmails = friends.map((friend) => friend.email).toList();
    final days = await Future.wait(
      buildWeekDays(referenceDate).map(
        (day) => scheduleRepository.getFriendsFreeSlotsWithCache(
          friendEmails: friendEmails,
          date: day,
        ),
      ),
    );

    return FriendsFreeSlotsWeekResult(
      freeSlots: FriendsFreeSlots(
        totalFriends: days.fold<int>(
          friends.length,
          (maxCount, day) => max(maxCount, day.freeSlots.totalFriends),
        ),
        slots: days.expand((day) => day.freeSlots.slots).toList(),
      ),
      isOffline: days.any((day) => day.isOffline),
      lastUpdated: _oldestCachedAt(days),
    );
  }

  DateTime? _oldestCachedAt(List<FriendsFreeSlotsResult> days) {
    final cachedDates =
        days
            .where((day) => day.isOffline && day.lastUpdated != null)
            .map((day) => day.lastUpdated!)
            .toList()
          ..sort();

    return cachedDates.isEmpty ? null : cachedDates.first;
  }

  static List<DateTime> buildWeekDays(DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));

    return List<DateTime>.generate(6, (index) {
      final day = weekStart.add(Duration(days: index));
      return DateTime(day.year, day.month, day.day);
    });
  }
}
