import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/dio_error_mapper.dart';
import '../../domain/usecases/delete_my_booking.dart';
import '../../domain/usecases/get_my_bookings.dart';
import 'my_bookings_state.dart';

class MyBookingsController extends StateNotifier<MyBookingsState> {
  MyBookingsController({
    required GetMyBookings getMyBookings,
    required DeleteMyBooking deleteMyBooking,
  }) : _getMyBookings = getMyBookings,
       _deleteMyBooking = deleteMyBooking,
       super(const MyBookingsState()) {
    Future.microtask(load);
  }

  final GetMyBookings _getMyBookings;
  final DeleteMyBooking _deleteMyBooking;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final bookings = await _getMyBookings();
      state = state.copyWith(isLoading: false, items: bookings);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _mapError(e));
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    final deleting = {...state.deletingIds, bookingId};
    state = state.copyWith(deletingIds: deleting, clearErrorMessage: true);

    try {
      await _deleteMyBooking(bookingId: bookingId);

      final updatedItems = state.items
          .where((item) => item.id != bookingId)
          .toList();

      final updatedDeleting = {...state.deletingIds}..remove(bookingId);

      state = state.copyWith(items: updatedItems, deletingIds: updatedDeleting);
    } catch (e) {
      final updatedDeleting = {...state.deletingIds}..remove(bookingId);

      state = state.copyWith(
        deletingIds: updatedDeleting,
        errorMessage: _mapError(e),
      );
    }
  }

  String _mapError(Object error) => DioErrorMapper.map(
        error,
        onBadResponse: (statusCode, detail) {
          if (detail != null) return detail;
          if (statusCode >= 400) return 'We could not load your bookings. Please try again.';
          return 'Something went wrong. Please try again.';
        },
      );
}
