import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  String _mapError(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'The server is not responding. Please try again later.';

        case DioExceptionType.connectionError:
          return 'No internet connection. Please check your connection and try again.';

        case DioExceptionType.badCertificate:
          return 'A secure connection could not be established. Please try again later.';

        case DioExceptionType.cancel:
          return 'The request was cancelled. Please try again.';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;

          if (data is Map && data['detail'] is String) {
            return data['detail'] as String;
          }

          if (statusCode != null && statusCode >= 500) {
            return 'The server is currently unavailable. Please try again later.';
          }

          if (statusCode != null && statusCode >= 400) {
            return 'We could not load your bookings. Please try again.';
          }

          return 'Something went wrong. Please try again.';

        case DioExceptionType.unknown:
          final message = error.message?.toLowerCase() ?? '';
          if (message.contains('socketexception') ||
              message.contains('failed host lookup') ||
              message.contains('network is unreachable')) {
            return 'No internet connection. Please check your connection and try again.';
          }
          if (message.contains('timeout')) {
            return 'The server is not responding. Please try again later.';
          }
          return 'Something went wrong. Please try again.';
      }
    }

    final raw = error.toString().toLowerCase();

    if (raw.contains('failed host lookup') ||
        raw.contains('socketexception') ||
        raw.contains('network is unreachable')) {
      return 'No internet connection. Please check your connection and try again.';
    }

    if (raw.contains('timeout')) {
      return 'The server is not responding. Please try again later.';
    }

    return 'Something went wrong. Please try again.';
  }
}
