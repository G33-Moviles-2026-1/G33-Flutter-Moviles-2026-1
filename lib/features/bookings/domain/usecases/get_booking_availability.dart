import '../../../../core/error/dio_error_mapper.dart';
import '../../../rooms/domain/entities/time_range.dart';
import '../../../rooms/domain/usecases/fetch_room_date_availability.dart';
import '../entities/booking_availability_data.dart';

class GetBookingAvailability {
  final FetchRoomDateAvailability _fetchRoomDateAvailability;

  const GetBookingAvailability(this._fetchRoomDateAvailability);

  Future<BookingAvailabilityData> call({
    required String roomId,
    required DateTime date,
    TimeRange? preferredTimeRange,
  }) async {
    try {
      final availability = await _fetchRoomDateAvailability(
        roomId: roomId,
        date: date,
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

      return BookingAvailabilityData(
        availableTimeRanges: ranges,
        selectedTimeRange: selectedRange,
      );
    } catch (error) {
      throw Exception(_mapError(error));
    }
  }

  bool _sameRange(TimeRange a, TimeRange b) {
    return a.start == b.start && a.end == b.end;
  }

  String _mapError(Object error) {
    return DioErrorMapper.map(
      error,
      onBadResponse: (statusCode, detail) {
        if (detail != null) return detail;
        if (statusCode >= 400) {
          return 'We could not load availability. Please try again.';
        }
        return 'Something went wrong. Please try again.';
      },
    );
  }
}