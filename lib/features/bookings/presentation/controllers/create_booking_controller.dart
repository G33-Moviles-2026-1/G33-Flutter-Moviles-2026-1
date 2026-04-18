import 'package:andespace/core/analytics/analytics_events.dart';
import 'package:andespace/core/analytics/analytics_service.dart';
import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:andespace/core/session/session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../rooms/domain/entities/time_range.dart';
import '../../../rooms/domain/entities/room_search.dart';
import '../../../rooms/domain/usecases/fetch_room_date_availability.dart';
import '../../domain/entities/booking_purpose.dart';
import '../../domain/usecases/create_booking.dart';
import 'create_booking_state.dart';

class CreateBookingController extends StateNotifier<CreateBookingState> {
  CreateBookingController({
    required this.room,
    required CreateBooking createBooking,
    required FetchRoomDateAvailability fetchRoomDateAvailability,
    required AnalyticsService analyticsService,
    required SessionController sessionController,
  })  : _createBooking = createBooking,
        _fetchRoomDateAvailability = fetchRoomDateAvailability,
        _analyticsService = analyticsService,
        _sessionController = sessionController,
        super(
          CreateBookingState.initial(
            _resolveInitialDate(sessionController),
          ),
        ) {
    _loadAvailabilityFor(
      state.selectedDate,
      preferredTimeRange: _resolveInitialPreferredTimeRange(sessionController),
    );
  }

  final RoomSearchItem room;
  final CreateBooking _createBooking;
  final FetchRoomDateAvailability _fetchRoomDateAvailability;
  final AnalyticsService _analyticsService;
  final SessionController _sessionController;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime _resolveInitialDate(SessionController sessionController) {
    final searchDate = sessionController.currentSearch?.date;
    if (searchDate == null) return _today();

    return DateTime(searchDate.year, searchDate.month, searchDate.day);
  }

  static TimeRange? _resolveInitialPreferredTimeRange(
    SessionController sessionController,
  ) {
    final search = sessionController.currentSearch;
    final start = search?.startTime;
    final end = search?.endTime;

    if (start == null || end == null) return null;
    return TimeRange(start: start, end: end);
  }

  DateTime get firstBookableDate => _today();
  DateTime get lastBookableDate => _today().add(const Duration(days: 7));

  Future<void> setDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);

    if (normalized.isBefore(firstBookableDate) ||
        normalized.isAfter(lastBookableDate)) {
      state = state.copyWith(
        errorMessage: 'You can only book for today and the next 7 days.',
        clearCreated: true,
      );
      return;
    }

    state = state.copyWith(
      selectedDate: normalized,
      clearErrorMessage: true,
      clearCreated: true,
    );

    await _loadAvailabilityFor(normalized);
  }

  void setTimeRange(TimeRange? range) {
    state = state.copyWith(
      selectedTimeRange: range,
      clearErrorMessage: true,
      clearCreated: true,
    );
  }

  void setPurpose(BookingPurpose purpose) {
    state = state.copyWith(
      selectedPurpose: purpose,
      clearErrorMessage: true,
      clearCreated: true,
    );
  }

  Future<void> submit() async {
    final selectedTimeRange = state.selectedTimeRange;

    if (state.isLoadingAvailability) {
      state = state.copyWith(
        errorMessage: 'Availability is still loading.',
        clearCreated: true,
      );
      return;
    }

    if (selectedTimeRange == null) {
      state = state.copyWith(
        errorMessage: 'Please select a valid available time slot.',
        clearCreated: true,
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearCreated: true,
    );

    try {
      final booking = await _createBooking(
        roomId: room.roomId,
        date: state.selectedDate,
        timeRange: selectedTimeRange,
        purpose: state.selectedPurpose,
      );

      await _trackBookingCreated(
        purpose: state.selectedPurpose,
        timeRange: selectedTimeRange,
      );

      state = state.copyWith(
        isSubmitting: false,
        created: booking,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _mapError(e),
        clearCreated: true,
      );
    }
  }

  Future<void> _loadAvailabilityFor(
    DateTime date, {
    TimeRange? preferredTimeRange,
  }) async {
    state = state.copyWith(
      isLoadingAvailability: true,
      availableTimeRanges: const [],
      clearSelectedTimeRange: true,
      clearAvailabilityErrorMessage: true,
      clearErrorMessage: true,
      clearCreated: true,
    );

    try {
      final availability = await _fetchRoomDateAvailability(
        roomId: room.roomId,
        date: _formatDate(date),
      );

      final ranges = availability.availableSlots
          .map((slot) => TimeRange(start: slot.start, end: slot.end))
          .toList()
        ..sort((a, b) => a.start.compareTo(b.start));

      TimeRange? selectedRange;
      if (preferredTimeRange != null) {
        for (final range in ranges) {
          if (_sameRange(range, preferredTimeRange)) {
            selectedRange = range;
            break;
          }
        }
      }

      selectedRange ??= ranges.isNotEmpty ? ranges.first : null;

      state = state.copyWith(
        isLoadingAvailability: false,
        availableTimeRanges: ranges,
        selectedTimeRange: selectedRange,
        clearSelectedTimeRange: ranges.isEmpty,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingAvailability: false,
        availabilityErrorMessage: _mapError(e),
        availableTimeRanges: const [],
        clearSelectedTimeRange: true,
      );
    }
  }

  bool _sameRange(TimeRange a, TimeRange b) {
    return a.start == b.start && a.end == b.end;
  }

  Future<void> _trackBookingCreated({
    required BookingPurpose purpose,
    required TimeRange timeRange,
  }) async {
    try {
      await _analyticsService.track(
        sessionId: _sessionController.sessionId,
        deviceId: _sessionController.deviceId,
        eventName: AnalyticsEvents.bookingCreated,
        screen: 'create_booking',
        propsJson: {
          'feature': 'bookings',
          'source_screen': 'create_booking',
          'room_id': room.roomId,
          'room_number': room.roomNumber,
          'building_code': room.buildingCode,
          'building_name': room.buildingName ?? room.buildingCode,
          'purpose': purpose.backendKey,
          'start_time': timeRange.start,
          'end_time': timeRange.end,
          'time_window': '${timeRange.start}-${timeRange.end}',
          'initial_status': 'active',
        },
      );
    } catch (_) {}
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _mapError(Object error) => DioErrorMapper.map(
        error,
        onBadResponse: (statusCode, detail) {
          if (detail != null) return detail;
          if (statusCode >= 400) return 'We could not complete your booking. Please try again.';
          return 'Something went wrong. Please try again.';
        },
      );
}