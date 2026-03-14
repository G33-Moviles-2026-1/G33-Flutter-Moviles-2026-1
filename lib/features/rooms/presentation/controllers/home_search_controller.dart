import 'package:andespace/core/analytics/analytics_events.dart';
import 'package:andespace/core/analytics/analytics_service.dart';
import 'package:andespace/core/session/session_controller.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/rooms/domain/usecases/search_rooms.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_search_state.dart';

class HomeSearchController extends StateNotifier<HomeSearchState> {
  HomeSearchController({
    required SearchRooms searchRooms,
    required AnalyticsService analyticsService,
    required SessionController sessionController,
  }) : _searchRooms = searchRooms,
       _analyticsService = analyticsService,
       _sessionController = sessionController,
       super(const HomeSearchState.initial());

  final SearchRooms _searchRooms;
  final AnalyticsService _analyticsService;
  final SessionController _sessionController;

  Future<void> onFiltersOpened() async {
    await _analyticsService.track(
      sessionId: _sessionController.sessionId,
      deviceId: _sessionController.deviceId,
      eventName: AnalyticsEvents.homeFiltersOpened,
      screen: 'home',
      propsJson: const {},
    );
  }

  Future<void> submitSearch({
    required String rawRoomInput,
    required String rawBuildingCodesInput,
    required DateTime? selectedDate,
    required TimeOfDay? since,
    required TimeOfDay? until,
    required Set<String> selectedUtilities,
    required bool nearMe,
    required int offset,
  }) async {
    final normalizedPrefixes = _normalizeCommaSeparated(rawRoomInput);
    final normalizedBuildingCodes = _normalizeCommaSeparated(
      rawBuildingCodesInput,
    );

    if (selectedDate == null) {
      state = HomeSearchState.error(
        'Please select a date.',
        previousResponse: state.response,
      );
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
      state = HomeSearchState.error(
        'Since must be earlier than Until.',
        previousResponse: state.response,
      );
      return;
    }

    final sessionLocation = nearMe ? _sessionController.currentLocation : null;
    if (nearMe && sessionLocation == null) {
      state = HomeSearchState.error(
        'Close to me requires location, and location is not available.',
        previousResponse: state.response,
      );
      return;
    }

    final request = RoomSearchRequest(
      roomPrefixes: normalizedPrefixes,
      date: _formatDate(selectedDate),
      since: since == null ? null : _formatTime24(since),
      until: until == null ? null : _formatTime24(until),
      buildingCodes: normalizedBuildingCodes,
      utilities: selectedUtilities.toList()..sort(),
      nearMe: nearMe,
      userLocation: sessionLocation == null
          ? null
          : SearchLocation(
              latitude: sessionLocation.latitude,
              longitude: sessionLocation.longitude,
            ),
      limit: 20,
      offset: offset,
    );

    state = HomeSearchState.loading(previousResponse: state.response);

    try {
      await _analyticsService.track(
        sessionId: _sessionController.sessionId,
        deviceId: _sessionController.deviceId,
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
      state = HomeSearchState.error(
        _mapError(e),
        previousResponse: state.response,
      );
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
    return value
        .replaceAll('-', ' ')
        .trim()
        .toUpperCase()
        .split(RegExp(r'\s+'))
        .join(' ');
  }

  bool _isStrictlyEarlier(TimeOfDay a, TimeOfDay b) {
    final aMinutes = a.hour * 60 + a.minute;
    final bMinutes = b.hour * 60 + b.minute;
    return aMinutes < bMinutes;
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatTime24(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _mapError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['detail'] is String) {
        return data['detail'] as String;
      }
      return error.message ?? 'Request failed.';
    }

    return error.toString();
  }


Future<void> goToPage(int page) async {
  final lastQuery = state.response?.query;
  if (lastQuery == null) return;
  final newOffset = (page - 1) * lastQuery.limit;
  final updatedRequest = lastQuery.copyWith(offset: newOffset);
  await _performSearch(updatedRequest);
}

Future<void> _performSearch(RoomSearchRequest request) async {
  state = HomeSearchState.loading(previousResponse: state.response);
  try {
    final response = await _searchRooms(request);
    state = HomeSearchState.success(response);
  } catch (e) {
    state = HomeSearchState.error(
      _mapError(e), 
      previousResponse: state.response,
    );
  }
}
}
