import 'package:dio/dio.dart';

import '../../domain/entities/room_detail.dart';
import '../../domain/entities/room_search.dart';
import '../../domain/repositories/rooms_repository.dart';
import '../models/room_dto.dart';
import '../models/room_search_request_dto.dart';
import '../models/room_search_response_dto.dart';
import '../remote/rooms_api.dart';

class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl({
    required this.dio,
    required this.roomsApi,
  });

  final Dio dio;
  final RoomsApi roomsApi;

  @override
  Future<RoomSearchResponse> searchRooms(RoomSearchRequest request) async {
    final requestDto = RoomSearchRequestDto(request);
    final raw = await roomsApi.searchRooms(requestDto.toJson());
    final responseDto = RoomSearchResponseDto.fromJson(raw);
    return responseDto.toDomain();
  }

  @override
  Future<RoomDetail> getRoomDetail(String roomId) async {
    final response = await dio.get('/rooms/$roomId');
    final dto = RoomDetailDto.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
    return dto.toDomain();
  }
}