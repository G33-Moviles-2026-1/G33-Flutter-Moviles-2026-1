import '../../../../core/di/core_provider.dart';
import '../../../rooms/domain/entities/time_range.dart';
import '../entities/create_booking_form_data.dart';

class GetCreateBookingInitialData {
  const GetCreateBookingInitialData();

  CreateBookingFormData call(SessionNotifier sessionNotifier) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final search = sessionNotifier.currentSearch;
    final searchDate = search?.date;

    final initialDate = searchDate == null
        ? today
        : DateTime(searchDate.year, searchDate.month, searchDate.day);

    final start = search?.startTime;
    final end = search?.endTime;

    final preferredTimeRange = (start != null && end != null)
        ? TimeRange(start: start, end: end)
        : null;

    return CreateBookingFormData(
      initialDate: initialDate,
      preferredTimeRange: preferredTimeRange,
    );
  }
}