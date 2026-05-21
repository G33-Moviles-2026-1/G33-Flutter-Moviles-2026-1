import 'package:dio/dio.dart';

class NotificationsApi {
  const NotificationsApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getNotifications() async {
    final response = await _dio.get('/notifications/');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> markRead(String notificationId) async {
    await _dio.put('/notifications/$notificationId/read');
  }

  Future<void> markAllRead() async {
    await _dio.put('/notifications/read-all');
  }
}
