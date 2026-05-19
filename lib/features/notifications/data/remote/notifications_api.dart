import 'package:dio/dio.dart';

class NotificationsApi {
  const NotificationsApi(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await _dio.get('/notifications/');
    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> markRead(String notificationId) async {
    await _dio.put('/notifications/$notificationId/read');
  }
}
