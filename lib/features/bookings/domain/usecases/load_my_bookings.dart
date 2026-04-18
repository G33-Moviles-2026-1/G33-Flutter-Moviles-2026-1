import '../../../../core/error/dio_error_mapper.dart';
import '../entities/my_booking.dart';
import 'get_my_bookings.dart';

class LoadMyBookings {
  final GetMyBookings _getMyBookings;

  const LoadMyBookings(this._getMyBookings);

  Future<List<MyBooking>> call() async {
    try {
      return await _getMyBookings();
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