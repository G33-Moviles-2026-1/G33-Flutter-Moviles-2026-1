import 'package:andespace/core/di/providers.dart';
import 'package:andespace/core/network/dio_provider.dart';
import 'package:andespace/features/rooms/data/remote/rooms_api.dart';
import 'package:andespace/features/rooms/data/repositories/rooms_repository_impl.dart';
import 'package:andespace/features/rooms/domain/repositories/rooms_repository.dart';
import 'package:andespace/features/rooms/domain/usecases/search_rooms.dart';
import 'package:andespace/features/rooms/presentation/controllers/home_search_controller.dart';
import 'package:andespace/features/rooms/presentation/controllers/home_search_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final roomsApiProvider = Provider<RoomsApi>((ref) {
  return RoomsApi(ref.read(dioProvider));
});

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return RoomRepositoryImpl(
    dio: ref.read(dioProvider),
    roomsApi: ref.read(roomsApiProvider),
  );
});

final searchRoomsUseCaseProvider = Provider<SearchRooms>((ref) {
  return SearchRooms(ref.read(roomRepositoryProvider));
});

final homeSearchControllerProvider =
    StateNotifierProvider.autoDispose<HomeSearchController, HomeSearchState>(
  (ref) {
    final searchRooms = ref.read(searchRoomsUseCaseProvider);
    final analyticsService = ref.read(analyticsServiceProvider);
    final sessionController = ref.read(sessionControllerProvider);

    return HomeSearchController(
      searchRooms: searchRooms,
      analyticsService: analyticsService,
      sessionController: sessionController,
    );
  },
);