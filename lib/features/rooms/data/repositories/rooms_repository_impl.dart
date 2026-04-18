import '../../domain/entities/room_date_availability.dart';
import '../../domain/entities/room_search.dart';
import '../../domain/repositories/rooms_repository.dart';
import '../models/room_date_availability_dto.dart';
import '../models/room_search_request_dto.dart';
import '../models/room_search_response_dto.dart';
import '../remote/rooms_api.dart';

class RoomRepositoryImpl implements RoomRepository {
  RoomRepositoryImpl({required this.roomsApi});

  final RoomsApi roomsApi;

  @override
  Future<RoomSearchResponse> searchRooms(RoomSearchRequest request) async {
    final requestDto = RoomSearchRequestDto(request);
    final raw = await roomsApi.searchRooms(requestDto.toJson());
    final responseDto = RoomSearchResponseDto.fromJson(raw);
    return responseDto.toDomain();
  }

  @override
  Future<RoomDateAvailability> fetchRoomDateAvailability({
    required String roomId,
    required String date,
  }) async {
    final raw = await roomsApi.fetchRoomDateAvailability(
      roomId: roomId,
      date: date,
    );

    final responseDto = RoomDateAvailabilityDto.fromJson(raw);
    return responseDto.toDomain();
  }
}