import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/core/utils/date_time_utils.dart';
import 'package:andespace/features/rooms/domain/entities/room_recommendation.dart';
import 'package:andespace/features/rooms/domain/usecases/auto_search_rooms.dart';
import 'package:andespace/features/rooms/domain/usecases/search_rooms_exceptions.dart';
import 'package:andespace/features/rooms/domain/usecases/submit_room_recommendation_interaction.dart';
import 'package:andespace/features/rooms/presentation/providers/rooms_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auto_search_state.dart';

class AutoSearchNotifier extends AutoDisposeNotifier<AutoSearchState> {
  late final AutoSearchRooms _autoSearchRooms;
  late final SubmitRoomRecommendationInteraction _submitInteraction;
  late final SessionNotifier _sessionNotifier;

  final Set<String> _excludedRoomIds = <String>{};

  @override
  AutoSearchState build() {
    _autoSearchRooms = ref.read(autoSearchRoomsUseCaseProvider);
    _submitInteraction = ref.read(
      submitRoomRecommendationInteractionUseCaseProvider,
    );
    _sessionNotifier = ref.read(sessionControllerProvider.notifier);
    return const AutoSearchState.initial();
  }

  Future<void> load({bool resetExclusions = true}) async {
    if (resetExclusions) {
      _excludedRoomIds.clear();
    }

    final now = DateTime.now();
    final targetDate = DateTimeUtils.toApiDate(now);
    final targetTime = DateTimeUtils.toApiTime(
      TimeOfDay(hour: now.hour, minute: now.minute),
    );
    final targetDay = DateTime(now.year, now.month, now.day);

    _sessionNotifier.updateSearchSelection(
      date: targetDay,
      startTime: targetTime,
      endTime: null,
    );

    state = AutoSearchState(
      status: AutoSearchStatus.loading,
      targetDate: targetDate,
      targetTime: targetTime,
    );

    try {
      final rooms = await _autoSearchRooms(
        AutoSearchRoomsRequest(
          targetDate: targetDate,
          targetTime: targetTime,
          excludeIds: _excludedRoomIds.toList()..sort(),
        ),
      );

      state = AutoSearchState(
        status: rooms.isEmpty
            ? AutoSearchStatus.empty
            : AutoSearchStatus.success,
        rooms: rooms,
        targetDate: targetDate,
        targetTime: targetTime,
      );
    } on SearchRoomsConnectivityException {
      state = state.copyWith(
        status: AutoSearchStatus.failure,
        errorMessage: 'No internet connection. Please try again later.',
      );
    } catch (error) {
      state = state.copyWith(
        status: AutoSearchStatus.failure,
        errorMessage: DioErrorMapper.map(
          error,
          onBadResponse: (statusCode, detail) {
            if (detail != null && detail.trim().isNotEmpty) return detail;
            if (statusCode == 401) return 'Please log in to use Auto Search.';
            return 'Auto Search is unavailable right now.';
          },
        ),
      );
    }
  }

  Future<void> skipCurrent() async {
    final room = state.currentRoom;
    if (room == null || state.isSubmittingInteraction) return;

    state = state.copyWith(
      isSubmittingInteraction: true,
      clearErrorMessage: true,
    );
    await _safeSubmit(RoomRecommendationAction.skip, room.roomId);

    await _excludeAndAdvance(room.roomId);
  }

  Future<void> advanceCurrent() async {
    final room = state.currentRoom;
    if (room == null || state.isSubmittingInteraction) return;

    state = state.copyWith(
      isSubmittingInteraction: true,
      clearErrorMessage: true,
    );

    await _excludeAndAdvance(room.roomId);
  }

  Future<void> _excludeAndAdvance(String roomId) async {
    _excludedRoomIds.add(roomId);
    final nextIndex = state.currentIndex + 1;

    if (nextIndex < state.rooms.length) {
      state = state.copyWith(
        currentIndex: nextIndex,
        isSubmittingInteraction: false,
      );
      return;
    }

    await load(resetExclusions: false);
  }

  Future<void> recordFavorite() async {
    final room = state.currentRoom;
    if (room == null || state.isSubmittingInteraction) return;

    state = state.copyWith(
      isSubmittingInteraction: true,
      clearErrorMessage: true,
    );
    await _safeSubmit(RoomRecommendationAction.favorite, room.roomId);
    _excludedRoomIds.add(room.roomId);
    state = state.copyWith(isSubmittingInteraction: false);
  }

  void undoFavoriteForCurrent() {
    final room = state.currentRoom;
    if (room == null) return;

    _excludedRoomIds.remove(room.roomId);
  }

  Future<void> recordBook() async {
    final room = state.currentRoom;
    if (room == null || state.isSubmittingInteraction) return;

    state = state.copyWith(
      isSubmittingInteraction: true,
      clearErrorMessage: true,
    );
    await _safeSubmit(RoomRecommendationAction.book, room.roomId);
    await _excludeAndAdvance(room.roomId);
  }

  Future<void> _safeSubmit(
    RoomRecommendationAction action,
    String roomId,
  ) async {
    try {
      await _submitInteraction(
        RoomRecommendationInteraction(
          roomId: roomId,
          action: action,
          weekday: _weekdayFromDate(state.targetDate),
          slotStart:
              state.targetTime ?? DateTimeUtils.toApiTime(TimeOfDay.now()),
        ),
      );
    } catch (_) {
      // Interaction feedback should improve learning, but it should not block
      // the user from booking, saving, or moving through recommendations.
    }
  }

  String _weekdayFromDate(String? rawDate) {
    final parsed = rawDate == null ? null : DateTime.tryParse(rawDate);
    switch (parsed?.weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return 'monday';
    }
  }
}

final autoSearchControllerProvider =
    NotifierProvider.autoDispose<AutoSearchNotifier, AutoSearchState>(
      AutoSearchNotifier.new,
    );
