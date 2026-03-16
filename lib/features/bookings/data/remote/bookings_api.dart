import 'package:dio/dio.dart';

class BookingsApi {
  BookingsApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> payload) async {
    final response = await _dio.post('/bookings/', data: payload);
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw const FormatException('Invalid create booking response format.');
  }

  Future<Map<String, dynamic>> fetchMyBookings() async {
    final response = await _dio.get('/bookings/mine');
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw const FormatException('Invalid my bookings response format.');
  }

  Future<void> deleteMyBooking({
    required String bookingId,
  }) async {
    await _dio.delete('/bookings/$bookingId');
  }
}