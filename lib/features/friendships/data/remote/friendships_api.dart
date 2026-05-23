import 'package:dio/dio.dart';

class FriendshipsApi {
  const FriendshipsApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> fetchMyFriends() async {
    final response = await _dio.get('/friendships/mine');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> fetchIncomingRequests() async {
    final response = await _dio.get('/friendships/requests/incoming');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> fetchOutgoingRequests() async {
    final response = await _dio.get('/friendships/requests/outgoing');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<String>> fetchSuggestions() async {
    final response = await _dio.get('/friendships/suggestions');
    final raw = response.data as List<dynamic>? ?? const [];
    return raw.map((e) => e.toString()).toList();
  }

  Future<void> sendFriendRequest(String usernameOrEmail) async {
    await _dio.post(
      '/friendships/',
      data: {'correo_amigo_2': usernameOrEmail.trim().toLowerCase()},
    );
  }

  Future<void> acceptFriendRequest(String usernameOrEmail) async {
    await _dio.put(
      '/friendships/accept',
      data: {'correo_amigo_1': usernameOrEmail.trim().toLowerCase()},
    );
  }

  Future<void> deleteFriendship(String usernameOrEmail) async {
    await _dio.delete(
      '/friendships/${Uri.encodeComponent(usernameOrEmail.trim().toLowerCase())}',
    );
  }

  Future<void> updateMyStatus(String status) async {
    await _dio.put('/me/status/', data: {'status': status});
  }
}