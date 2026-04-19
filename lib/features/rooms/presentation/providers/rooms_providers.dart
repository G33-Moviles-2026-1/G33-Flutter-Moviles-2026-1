import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/features/rooms/data/remote/rooms_api.dart';
import 'package:andespace/features/rooms/data/repositories/rooms_repository_impl.dart';
import 'package:andespace/features/rooms/domain/repositories/rooms_repository.dart';
import 'package:andespace/features/rooms/domain/usecases/fetch_room_date_availability.dart';
import 'package:andespace/features/rooms/domain/usecases/search_rooms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final roomsApiProvider = Provider<RoomsApi>((ref) {
  return RoomsApi(ref.watch(dioProvider));
});

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return RoomRepositoryImpl(roomsApi: ref.watch(roomsApiProvider));
});

final searchRoomsUseCaseProvider = Provider<SearchRooms>((ref) {
  return SearchRooms(ref.watch(roomRepositoryProvider));
});

final fetchRoomDateAvailabilityUseCaseProvider =
    Provider<FetchRoomDateAvailability>((ref) {
      return FetchRoomDateAvailability(ref.watch(roomRepositoryProvider));
    });