import '../../../rooms/domain/entities/time_range.dart';

class BookingAvailabilityData {
  final List<TimeRange> availableTimeRanges;
  final TimeRange? selectedTimeRange;

  const BookingAvailabilityData({
    required this.availableTimeRanges,
    required this.selectedTimeRange,
  });
}