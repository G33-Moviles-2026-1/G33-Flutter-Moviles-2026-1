import 'package:dio/dio.dart';

class RoomsApi {
  RoomsApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> searchRooms(Map<String, dynamic> body) async {
    final response = await _dio.post('/rooms/search', data: body);

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> fetchRoomDateAvailability({
    required String roomId,
    required String date,
  }) async {
    final response = await _dio.get(
      '/rooms/$roomId/availability',
      queryParameters: {'date_value': date},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw const FormatException('Invalid room availability response format.');
  }
}