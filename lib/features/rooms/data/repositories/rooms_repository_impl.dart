import 'package:dio/dio.dart';

import '../../domain/entities/room_detail.dart';
import '../../domain/repositories/rooms_repository.dart';
import '../models/room_dto.dart';

class RoomRepositoryImpl implements RoomRepository {
  final Dio dio;

  RoomRepositoryImpl(this.dio);

  @override
  Future<RoomDetail> getRoomDetail(String roomId) async {
    final response = await dio.get('/rooms/$roomId');

    final dto = RoomDetailDto.fromJson(response.data);

    return dto.toDomain();
  }
}