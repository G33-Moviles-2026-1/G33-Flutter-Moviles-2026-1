import 'package:dio/dio.dart';

import '../../../../core/analytics/analytics_events.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/di/core_provider.dart';
import '../../../../core/error/dio_error_mapper.dart';
import '../../../rooms/domain/entities/room_search.dart';
import '../../../rooms/domain/entities/time_range.dart';
import '../entities/booking.dart';
import '../entities/booking_purpose.dart';
import 'create_booking.dart';

class SubmitBooking {
  final CreateBooking _createBooking;
  final AnalyticsService _analyticsService;

  const SubmitBooking(this._createBooking, this._analyticsService);

  Future<Booking> call({
    required RoomSearchItem room,
    required DateTime selectedDate,
    required TimeRange? selectedTimeRange,
    required BookingPurpose selectedPurpose,
    required bool isLoadingAvailability,
    required SessionNotifier sessionNotifier,
  }) async {
    if (isLoadingAvailability) {
      throw Exception('Availability is still loading.');
    }

    if (selectedTimeRange == null) {
      throw Exception('Please select a valid available time slot.');
    }

    try {
      final booking = await _createBooking(
        roomId: room.roomId,
        date: selectedDate,
        timeRange: selectedTimeRange,
        purpose: selectedPurpose,
      );

      await _trackBookingCreated(
        room: room,
        purpose: selectedPurpose,
        timeRange: selectedTimeRange,
        sessionNotifier: sessionNotifier,
      );

      return booking;
    } catch (error) {
      if (error is DioException && error.response == null) rethrow;
      throw Exception(_mapError(error));
    }
  }

  Future<void> _trackBookingCreated({
    required RoomSearchItem room,
    required BookingPurpose purpose,
    required TimeRange timeRange,
    required SessionNotifier sessionNotifier,
  }) async {
    try {
      await _analyticsService.track(
        sessionId: sessionNotifier.sessionId,
        deviceId: sessionNotifier.deviceId,
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

  String _mapError(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }

    return DioErrorMapper.map(
      error,
      onBadResponse: (statusCode, detail) {
        if (detail != null) return detail;
        if (statusCode >= 400) {
          return 'We could not complete your booking. Please try again.';
        }
        return 'Something went wrong. Please try again.';
      },
    );
  }
}