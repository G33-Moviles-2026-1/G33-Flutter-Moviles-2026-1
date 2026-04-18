import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/load_my_bookings.dart';
import '../../domain/usecases/remove_booking_from_list.dart';
import '../providers/bookings_providers.dart';
import 'my_bookings_state.dart';

class MyBookingsNotifier extends AutoDisposeNotifier<MyBookingsState> {
  late final LoadMyBookings _loadMyBookings;
  late final RemoveBookingFromList _removeBookingFromList;

  @override
  MyBookingsState build() {
    _loadMyBookings = ref.read(loadMyBookingsUseCaseProvider);
    _removeBookingFromList = ref.read(removeBookingFromListUseCaseProvider);

    Future.microtask(load);

    return const MyBookingsState();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final bookings = await _loadMyBookings();
      state = state.copyWith(
        isLoading: false,
        items: bookings,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    final deleting = {...state.deletingIds, bookingId};

    state = state.copyWith(
      deletingIds: deleting,
      clearErrorMessage: true,
    );

    try {
      final updatedItems = await _removeBookingFromList(
        bookingId: bookingId,
        currentItems: state.items,
      );

      final updatedDeleting = {...state.deletingIds}..remove(bookingId);

      state = state.copyWith(
        items: updatedItems,
        deletingIds: updatedDeleting,
      );
    } catch (error) {
      final updatedDeleting = {...state.deletingIds}..remove(bookingId);

      state = state.copyWith(
        deletingIds: updatedDeleting,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final myBookingsControllerProvider =
    NotifierProvider.autoDispose<MyBookingsNotifier, MyBookingsState>(
  MyBookingsNotifier.new,
);