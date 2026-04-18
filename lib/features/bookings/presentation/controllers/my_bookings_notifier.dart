import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/delete_my_booking.dart';
import '../../domain/usecases/get_my_bookings.dart';
import '../providers/bookings_providers.dart';
import 'my_bookings_state.dart';

class MyBookingsNotifier extends AutoDisposeNotifier<MyBookingsState> {
  late final GetMyBookings _getMyBookings;
  late final DeleteMyBooking _deleteMyBooking;

  @override
  MyBookingsState build() {
    _getMyBookings = ref.read(getMyBookingsUseCaseProvider);
    _deleteMyBooking = ref.read(deleteMyBookingUseCaseProvider);
    Future.microtask(load);
    return const MyBookingsState();
  }

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
      final updatedItems = state.items.where((item) => item.id != bookingId).toList();
      final updatedDeleting = {...state.deletingIds}..remove(bookingId);
      state = state.copyWith(items: updatedItems, deletingIds: updatedDeleting);
    } catch (e) {
      final updatedDeleting = {...state.deletingIds}..remove(bookingId);
      state = state.copyWith(deletingIds: updatedDeleting, errorMessage: _mapError(e));
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

final myBookingsControllerProvider =
    NotifierProvider.autoDispose<MyBookingsNotifier, MyBookingsState>(MyBookingsNotifier.new);
