import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:andespace/features/rooms/domain/entities/room_date_availability.dart';
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
  @override
  RoomDetailState build() => RoomDetailState();

  Future<void> loadAvailability(String roomId, String date) async {
    final fetchRoomDateAvailability = ref.read(fetchRoomDateAvailabilityUseCaseProvider);
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await fetchRoomDateAvailability(roomId: roomId, date: date);
      state = state.copyWith(availability: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: DioErrorMapper.map(e));
    }
  }
}

final roomDetailControllerProvider =
    NotifierProvider.autoDispose<RoomDetailNotifier, RoomDetailState>(RoomDetailNotifier.new);
