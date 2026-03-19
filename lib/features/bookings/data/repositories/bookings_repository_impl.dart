import 'package:dio/dio.dart';

import '../../../rooms/domain/entities/time_range.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_purpose.dart';
import '../../domain/entities/my_booking.dart';
import '../../domain/repositories/bookings_repository.dart';
import '../models/booking_response_dto.dart';
import '../models/create_booking_request_dto.dart';
import '../models/my_bookings_response_dto.dart';
import '../remote/bookings_api.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  BookingsRepositoryImpl({
    required this.dio,
    required this.bookingsApi,
  });

  final Dio dio;
  final BookingsApi bookingsApi;

  @override
  Future<Booking> createBooking({
    required String roomId,
    required DateTime date,
    required TimeRange timeRange,
    required BookingPurpose purpose,
  }) async {
    final requestDto = CreateBookingRequestDto(
      roomId: roomId,
      date: date,
      timeRange: timeRange,
      purpose: purpose,
    );

    final raw = await bookingsApi.createBooking(requestDto.toJson());
    final dto = BookingResponseDto.fromJson(raw);
    return dto.toDomain();
  }

  @override
  Future<List<MyBooking>> getMyBookings() async {
    final raw = await bookingsApi.fetchMyBookings();
    final dto = MyBookingsResponseDto.fromJson(raw);
    return dto.toDomain();
  }

  @override
  Future<void> deleteMyBooking({
    required String bookingId,
  }) {
    return bookingsApi.deleteMyBooking(bookingId: bookingId);
  }
}