import 'package:andespace/core/analytics/analytics_events.dart';
import 'package:andespace/core/analytics/analytics_service.dart';
import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:andespace/core/utils/date_time_utils.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/rooms/domain/usecases/search_rooms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/rooms_providers.dart';
import 'home_search_state.dart';

class HomeSearchNotifier extends AutoDisposeNotifier<HomeSearchState> {
  late final SearchRooms _searchRooms;
  late final AnalyticsService _analyticsService;
  late final SessionNotifier _sessionNotifier;

  @override
  HomeSearchState build() {
    _searchRooms = ref.read(searchRoomsUseCaseProvider);
    _analyticsService = ref.read(analyticsServiceProvider);
    _sessionNotifier = ref.read(sessionControllerProvider.notifier);
    return const HomeSearchState.initial();
  }

  Future<void> onFiltersOpened() async {
    await _analyticsService.track(
      sessionId: _sessionNotifier.sessionId,
      deviceId: _sessionNotifier.deviceId,
      eventName: AnalyticsEvents.homeFiltersOpened,
      screen: 'home',
      propsJson: const {},
    );
  }

  Future<void> submitSearch({
    required String rawRoomInput,
    required DateTime? selectedDate,
    required TimeOfDay? since,
    required TimeOfDay? until,
    required Set<String> selectedUtilities,
    required bool nearMe,
    required int offset,
  }) async {
    if (selectedDate == null) {
      state = HomeSearchState.error('Please select a date.', previousResponse: state.response);
      return;
    }

    if (nearMe) {
      state = HomeSearchState.loading(previousResponse: state.response);
      await _sessionNotifier.refreshLocation();
    }

    final sessionLocation = nearMe ? _sessionNotifier.currentLocation : null;

    if (nearMe && sessionLocation == null) {
      state = const HomeSearchState.error('No se pudo obtener tu ubicación GPS.');
      return;
    }

    final sinceStr = since == null ? null : DateTimeUtils.toApiTime(since);
    final untilStr = until == null ? null : DateTimeUtils.toApiTime(until);

    _sessionNotifier.updateSearchSelection(
      date: selectedDate,
      startTime: sinceStr,
      endTime: untilStr,
    );

    final input = SearchRoomsInput(
      rawRoomInput: rawRoomInput,
      date: DateTimeUtils.toApiDate(selectedDate),
      since: sinceStr,
      until: untilStr,
      utilities: selectedUtilities,
      nearMe: nearMe,
      userLocation: sessionLocation == null
          ? null
          : SearchLocation(latitude: sessionLocation.latitude, longitude: sessionLocation.longitude),
      offset: offset,
    );

    state = HomeSearchState.loading(previousResponse: state.response);

    try {
      await _analyticsService.track(
        sessionId: _sessionNotifier.sessionId,
        deviceId: _sessionNotifier.deviceId,
        eventName: AnalyticsEvents.homeSearchSubmitted,
        screen: 'home',
        propsJson: {
          'utilities_count': selectedUtilities.length,
          'near_me': nearMe,
          'has_since': since != null,
          'has_until': until != null,
        },
      );

      final response = await _searchRooms(input);
      state = HomeSearchState.success(response);
    } on SearchRoomsValidationException catch (e) {
      state = HomeSearchState.error(e.message, previousResponse: state.response);
    } catch (e) {
      state = HomeSearchState.error(_mapError(e), previousResponse: state.response);
    }
  }

  Future<void> goToPage(int page) async {
    final lastResponse = state.response;
    if (lastResponse == null) return;
    final lastQuery = lastResponse.query;
    final newOffset = (page - 1) * lastQuery.limit;
    SearchLocation? recoveredLocation = lastQuery.userLocation;

    if (lastQuery.nearMe && recoveredLocation == null) {
      final currentSessionLoc = _sessionNotifier.currentLocation;
      if (currentSessionLoc != null) {
        recoveredLocation = SearchLocation(
          latitude: currentSessionLoc.latitude,
          longitude: currentSessionLoc.longitude,
        );
      }
    }

    final updatedRequest = lastQuery.copyWith(offset: newOffset, userLocation: recoveredLocation);
    await _performSearch(updatedRequest);
  }

  Future<void> _performSearch(RoomSearchRequest request) async {
    state = HomeSearchState.loading(previousResponse: state.response);
    try {
      final response = await _searchRooms.callWithRequest(request);
      state = HomeSearchState.success(response);
    } catch (e) {
      state = HomeSearchState.error(_mapError(e), previousResponse: state.response);
    }
  }

  String _mapError(Object error) => DioErrorMapper.map(
        error,
        onBadResponse: (statusCode, detail) {
          if (statusCode >= 400) return 'We could not complete your search. Please try again.';
          return 'Something went wrong. Please try again.';
        },
      );
}

final homeSearchControllerProvider =
    NotifierProvider.autoDispose<HomeSearchNotifier, HomeSearchState>(HomeSearchNotifier.new);
