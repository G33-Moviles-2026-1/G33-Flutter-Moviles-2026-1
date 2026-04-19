import 'package:dio/dio.dart';

class FavoritesApi {
  FavoritesApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> fetchMyFavorites() async {
    final response = await _dio.get('/favorites/mine');
    final data = response.data;

    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw const FormatException('Invalid favorites response format.');
  }

  Future<void> createFavorite(String roomId) async {
    await _dio.post(
      '/favorites/',
      data: {
        'room_id': roomId,
      },
    );
  }

  Future<void> deleteFavorite(String roomId) async {
    await _dio.delete('/favorites/${Uri.encodeComponent(roomId)}');
  }
}