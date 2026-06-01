import 'package:andespace/features/friendships/domain/entities/friend.dart';
import 'package:andespace/features/friendships/domain/usecases/load_friend_schedule_usecase.dart';
import 'package:andespace/features/friendships/presentation/providers/friendships_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'friend_schedule_state.dart';

class FriendScheduleNotifier
    extends AutoDisposeFamilyNotifier<FriendScheduleState, Friend> {
  late final LoadFriendScheduleUseCase _loadFriendSchedule;

  @override
  FriendScheduleState build(Friend arg) {
    _loadFriendSchedule = ref.read(loadFriendScheduleUseCaseProvider);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Future.microtask(loadSchedule);

    return FriendScheduleState(referenceDate: today);
  }

  Future<void> loadSchedule() async {
    state = state.copyWith(
      status: FriendScheduleStatus.loading,
      clearErrorMessage: true,
      isOffline: false,
      clearLastUpdated: true,
    );

    try {
      final result = await _loadFriendSchedule(
        friend: arg,
        referenceDate: state.referenceDate,
      );

      state = state.copyWith(
        status: FriendScheduleStatus.success,
        schedule: result.schedule,
        isOffline: result.isOffline,
        lastUpdated: result.lastUpdated,
      );
    } catch (error) {
      state = state.copyWith(
        status: FriendScheduleStatus.error,
        clearSchedule: true,
        isOffline: false,
        clearLastUpdated: true,
        errorMessage: _mapScheduleError(error),
      );
    }
  }

  void goToPreviousWeek() {
    state = state.copyWith(
      referenceDate: state.referenceDate.subtract(const Duration(days: 7)),
    );
    loadSchedule();
  }

  void goToNextWeek() {
    state = state.copyWith(
      referenceDate: state.referenceDate.add(const Duration(days: 7)),
    );
    loadSchedule();
  }

  String _mapScheduleError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final detail = _extractDetail(error.response?.data);

      if (statusCode == 403) {
        return '${arg.username} does not share their schedule.';
      }

      if (statusCode == 404) {
        return '${arg.username} does not have a schedule yet.';
      }

      if (detail != null && detail.trim().isNotEmpty) {
        return detail.trim();
      }

      if (error.response == null) {
        return 'Could not load ${arg.username}\'s schedule. Check your connection.';
      }
    }

    return 'Could not load ${arg.username}\'s schedule.';
  }

  String? _extractDetail(Object? data) {
    if (data is Map) {
      final detail = data['detail'];
      if (detail != null) return detail.toString();
    }
    return null;
  }
}
