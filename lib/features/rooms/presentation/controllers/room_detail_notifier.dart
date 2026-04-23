import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:andespace/features/rooms/domain/entities/room_date_availability.dart';
import 'package:andespace/features/rooms/domain/usecases/fetch_room_date_availability.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/rooms_providers.dart';

class RoomDetailState {
  final RoomDateAvailability? availability;
  final bool isLoading;
  final String? error;

  RoomDetailState({this.availability, this.isLoading = false, this.error});

  RoomDetailState copyWith({
    RoomDateAvailability? availability,
    bool? isLoading,
    String? error,
  }) {
    return RoomDetailState(
      availability: availability ?? this.availability,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class RoomDetailNotifier extends AutoDisposeNotifier<RoomDetailState> {
  late final FetchRoomDateAvailability _fetchRoomDateAvailability;

  @override
  RoomDetailState build() {
    _fetchRoomDateAvailability = ref.read(fetchRoomDateAvailabilityUseCaseProvider);
    return RoomDetailState();
  }

  Future<void> loadAvailability(String roomId, DateTime date) async {
    state = RoomDetailState(isLoading: true);
    try {
      final result = await _fetchRoomDateAvailability(roomId: roomId, date: date);
      state = RoomDetailState(availability: result);
    } catch (e) {
      state = RoomDetailState(error: DioErrorMapper.map(e));
    }
  }
}

final roomDetailControllerProvider =
    NotifierProvider.autoDispose<RoomDetailNotifier, RoomDetailState>(RoomDetailNotifier.new);
