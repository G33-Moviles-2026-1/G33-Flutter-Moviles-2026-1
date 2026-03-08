import 'package:dio/dio.dart';

class RoomsApi {
  RoomsApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> searchRooms(Map<String, dynamic> body) async {
    final response = await _dio.post(
      '/rooms/search',
      data: body,
    );

    return Map<String, dynamic>.from(response.data as Map);
  }
}