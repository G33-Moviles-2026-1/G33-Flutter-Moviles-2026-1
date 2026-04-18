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
    final normalizedPrefixes = _normalizeCommaSeparated(rawRoomInput);

    if (selectedDate == null) {
      state = HomeSearchState.error('Please select a date.', previousResponse: state.response);
      return;
    }

    if (since == null && until == null) {
      state = HomeSearchState.error(
        'Please provide at least one of Since or Until.',
        previousResponse: state.response,
      );
      return;
    }

    if (since != null && until != null && !_isStrictlyEarlier(since, until)) {
      state = HomeSearchState.error('Since must be earlier than Until.', previousResponse: state.response);
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

    _sessionNotifier.updateSearchSelection(
      date: selectedDate,
      startTime: since == null ? null : DateTimeUtils.toApiTime(since),
      endTime: until == null ? null : DateTimeUtils.toApiTime(until),
    );

    final request = RoomSearchRequest(
      roomPrefixes: normalizedPrefixes,
      date: DateTimeUtils.toApiDate(selectedDate),
      since: since == null ? null : DateTimeUtils.toApiTime(since),
      until: until == null ? null : DateTimeUtils.toApiTime(until),
      buildingCodes: const [],
      utilities: selectedUtilities.toList()..sort(),
      nearMe: nearMe,
      userLocation: sessionLocation == null
          ? null
          : SearchLocation(latitude: sessionLocation.latitude, longitude: sessionLocation.longitude),
      limit: 20,
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
          'room_prefixes_count': request.roomPrefixes.length,
          'building_codes_count': request.buildingCodes.length,
          'utilities_count': request.utilities.length,
          'near_me': request.nearMe,
          'has_since': request.since != null,
          'has_until': request.until != null,
        },
      );

      final response = await _searchRooms(request);
      state = HomeSearchState.success(response);
    } catch (e) {
      state = HomeSearchState.error(_mapError(e), previousResponse: state.response);
    }
  }

  List<String> _normalizeCommaSeparated(String raw) {
    return raw
        .split(',')
        .map(_normalizeToken)
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  String _normalizeToken(String value) {
    return value.replaceAll('-', ' ').trim().toUpperCase().split(RegExp(r'\s+')).join(' ');
  }

  bool _isStrictlyEarlier(TimeOfDay a, TimeOfDay b) {
    return (a.hour * 60 + a.minute) < (b.hour * 60 + b.minute);
  }


  String _mapError(Object error) => DioErrorMapper.map(
        error,
        onBadResponse: (statusCode, detail) {
          if (statusCode >= 400) return 'We could not complete your search. Please try again.';
          return 'Something went wrong. Please try again.';
        },
      );

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
      final response = await _searchRooms(request);
      state = HomeSearchState.success(response);
    } catch (e) {
      state = HomeSearchState.error(_mapError(e), previousResponse: state.response);
    }
  }
}

final homeSearchControllerProvider =
    NotifierProvider.autoDispose<HomeSearchNotifier, HomeSearchState>(HomeSearchNotifier.new);
