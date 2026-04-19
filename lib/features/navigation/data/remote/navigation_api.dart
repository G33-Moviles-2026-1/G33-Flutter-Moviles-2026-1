import 'package:dio/dio.dart';

class NavigationApi {
  const NavigationApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getNearestNode({
    required double lat,
    required double lon,
  }) async {
    final response = await _dio.get(
      '/navigation/nearest-node',
      queryParameters: {'lat': lat, 'lon': lon},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> getNavigationPath({
    required String fromRoom,
    required String toRoom,
  }) async {
    final response = await _dio.get(
      '/navigation/path',
      queryParameters: {'from_room': fromRoom, 'to_room': toRoom},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return Map<String, dynamic>.from(data as Map);
  }
}