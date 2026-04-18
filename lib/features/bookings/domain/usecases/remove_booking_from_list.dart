import '../../../../core/error/dio_error_mapper.dart';
import '../entities/my_booking.dart';
import 'delete_my_booking.dart';

class RemoveBookingFromList {
  final DeleteMyBooking _deleteMyBooking;

  const RemoveBookingFromList(this._deleteMyBooking);

  Future<List<MyBooking>> call({
    required String bookingId,
    required List<MyBooking> currentItems,
  }) async {
    try {
      await _deleteMyBooking(bookingId: bookingId);
      return currentItems.where((item) => item.id != bookingId).toList();
    } catch (error) {
      throw Exception(_mapError(error));
    }
  }

  String _mapError(Object error) {
    return DioErrorMapper.map(
      error,
      onBadResponse: (statusCode, detail) {
        if (detail != null) return detail;
        if (statusCode >= 400) {
          return 'We could not load your bookings. Please try again.';
        }
        return 'Something went wrong. Please try again.';
      },
    );
  }
}