import 'package:dio/dio.dart' show DioException;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/connectivity/connectivity_queue_service.dart';
import '../../../../core/di/core_provider.dart';
import '../../data/actions/delete_booking_action.dart';
import '../../data/local/bookings_local_datasource.dart';
import '../../data/remote/bookings_api.dart';
import '../../domain/entities/my_booking.dart';
import '../../domain/usecases/get_cached_bookings.dart';
import '../../domain/usecases/load_my_bookings.dart';
import '../../domain/usecases/remove_booking_from_list.dart';
import '../providers/bookings_providers.dart';
import 'my_bookings_state.dart';

class MyBookingsNotifier extends AutoDisposeNotifier<MyBookingsState> {
  late final GetCachedBookings _getCachedBookings;
  late final LoadMyBookings _loadMyBookings;
  late final RemoveBookingFromList _removeBookingFromList;
  late final BookingsLocalDataSource _localDataSource;
  late final ConnectivityQueueService _queueService;
  late final BookingsApi _bookingsApi;

  @override
  MyBookingsState build() {
    _getCachedBookings = ref.read(getCachedBookingsUseCaseProvider);
    _loadMyBookings = ref.read(loadMyBookingsUseCaseProvider);
    _removeBookingFromList = ref.read(removeBookingFromListUseCaseProvider);
    _localDataSource = ref.read(bookingsLocalDataSourceProvider);
    _queueService = ref.read(connectivityQueueServiceProvider);
    _bookingsApi = ref.read(bookingsApiProvider);
    Future.microtask(load);
    return const MyBookingsState();
  }

  Future<void> load() async {
    List<MyBooking> cached = [];
    try {
      cached = await _getCachedBookings();
    } catch (_) {}
    state = state.copyWith(
      items: cached.isNotEmpty ? cached : state.items,
      isLoading: true,
      clearErrorMessage: true,
    );

    try {
      final fresh = await _loadMyBookings();
      state = state.copyWith(isLoading: false, items: fresh);
    } catch (error) {
      if (cached.isNotEmpty) {
        state = state.copyWith(isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    state = state.copyWith(
      deletingIds: {...state.deletingIds, bookingId},
      clearErrorMessage: true,
    );

    try {
      final updatedItems = await _removeBookingFromList(
        bookingId: bookingId,
        currentItems: state.items,
      );
      state = state.copyWith(
        items: updatedItems,
        deletingIds: {...state.deletingIds}..remove(bookingId),
      );
    } catch (error) {
      if (error is DioException && error.response == null) {
        try {
          await _localDataSource.removeBooking(bookingId);
        } catch (_) {}
        state = state.copyWith(
          items: state.items.where((i) => i.id != bookingId).toList(),
          deletingIds: {...state.deletingIds}..remove(bookingId),
          pendingSyncMessage:
              'Deletion queued — not confirmed yet. If you close the app before connection is restored, this action will be lost.',
        );
        _queueService.enqueue(DeleteBookingAction(_bookingsApi, bookingId));
      } else {
        state = state.copyWith(
          deletingIds: {...state.deletingIds}..remove(bookingId),
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }
}

final myBookingsControllerProvider =
    NotifierProvider.autoDispose<MyBookingsNotifier, MyBookingsState>(
  MyBookingsNotifier.new,
);