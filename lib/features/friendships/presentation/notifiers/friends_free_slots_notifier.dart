import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:andespace/features/friendships/domain/entities/free_slot_selection.dart';
import 'package:andespace/features/friendships/domain/entities/friend.dart';
import 'package:andespace/features/friendships/domain/entities/friends_free_slots_room_recommendations.dart';
import 'package:andespace/features/friendships/domain/usecases/find_rooms_for_free_slots_usecase.dart';
import 'package:andespace/features/friendships/domain/usecases/load_friends_free_slots_for_week_usecase.dart';
import 'package:andespace/features/friendships/presentation/providers/friendships_providers.dart';
import 'package:andespace/features/rooms/domain/usecases/search_rooms_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'friends_free_slots_state.dart';

class FriendsFreeSlotsNotifier
    extends AutoDisposeFamilyNotifier<FriendsFreeSlotsState, List<Friend>> {
  late final LoadFriendsFreeSlotsForWeekUseCase _loadFreeSlots;
  late final FindRoomsForFreeSlotsUseCase _findRooms;

  @override
  FriendsFreeSlotsState build(List<Friend> arg) {
    _loadFreeSlots = ref.read(loadFriendsFreeSlotsForWeekUseCaseProvider);
    _findRooms = ref.read(findRoomsForFreeSlotsUseCaseProvider);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Future.microtask(loadFreeSlots);

    return FriendsFreeSlotsState(referenceDate: today);
  }

  Future<void> loadFreeSlots() async {
    state = state.copyWith(
      status: FriendsFreeSlotsStatus.loading,
      selectedSlots: const {},
      clearErrorMessage: true,
      clearFindRoomsErrorMessage: true,
    );

    try {
      final freeSlots = await _loadFreeSlots(
        friends: arg,
        referenceDate: state.referenceDate,
      );

      state = state.copyWith(
        status: FriendsFreeSlotsStatus.success,
        freeSlots: freeSlots,
      );
    } catch (error) {
      state = state.copyWith(
        status: FriendsFreeSlotsStatus.error,
        clearFreeSlots: true,
        errorMessage: _mapFreeSlotsError(error),
      );
    }
  }

  void goToPreviousWeek() {
    state = state.copyWith(
      referenceDate: state.referenceDate.subtract(const Duration(days: 7)),
      selectedSlots: const {},
    );
    loadFreeSlots();
  }

  void goToNextWeek() {
    state = state.copyWith(
      referenceDate: state.referenceDate.add(const Duration(days: 7)),
      selectedSlots: const {},
    );
    loadFreeSlots();
  }

  void toggleSlot(FreeSlotSelection slot) {
    final selected = {...state.selectedSlots};

    if (selected.containsKey(slot.key)) {
      selected.remove(slot.key);
    } else {
      selected[slot.key] = slot;
    }

    state = state.copyWith(selectedSlots: selected);
  }

  void clearSelectedSlots() {
    state = state.copyWith(selectedSlots: const {});
  }

  Future<FriendsFreeSlotsRoomRecommendations?>
  findRoomsForSelectedSlots() async {
    if (state.selectedSlots.isEmpty || state.isFindingRooms) return null;

    state = state.copyWith(
      isFindingRooms: true,
      clearFindRoomsErrorMessage: true,
    );

    try {
      return await _findRooms(selections: state.selectedSlots.values);
    } on SearchRoomsConnectivityException {
      state = state.copyWith(
        findRoomsErrorMessage:
            'No internet connection. Please check your connection and try again.',
      );
      return null;
    } catch (error) {
      state = state.copyWith(findRoomsErrorMessage: _mapFindRoomsError(error));
      return null;
    } finally {
      state = state.copyWith(isFindingRooms: false);
    }
  }

  String _mapFreeSlotsError(Object error) {
    return DioErrorMapper.map(
      error,
      fallback: 'Could not load free slots. Pull to retry.',
      onBadResponse: (statusCode, detail) {
        if (detail != null && detail.trim().isNotEmpty) {
          return detail.trim();
        }

        if (statusCode == 400) return 'Select at least one friend.';
        if (statusCode == 401) return 'Please log in again.';
        if (statusCode == 403) {
          return 'One or more friends are not sharing their schedule.';
        }
        if (statusCode == 404) return 'No schedules were found.';

        return 'Could not load free slots. Pull to retry.';
      },
    ).replaceFirst('Exception: ', '');
  }

  String _mapFindRoomsError(Object error) {
    return DioErrorMapper.map(
      error,
      fallback: 'Could not find rooms for the selected slots.',
      onBadResponse: (statusCode, detail) {
        if (detail != null && detail.trim().isNotEmpty) {
          return detail.trim();
        }

        if (statusCode >= 500) {
          return 'The server is currently unavailable. Please try again later.';
        }

        return 'Could not find rooms for the selected slots.';
      },
    ).replaceFirst('Exception: ', '');
  }
}
