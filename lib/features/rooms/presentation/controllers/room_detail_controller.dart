import 'package:andespace/features/rooms/domain/entities/room_date_availability.dart';
import 'package:andespace/features/rooms/domain/usecases/fetch_room_date_availability.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class RoomDetailController extends StateNotifier<RoomDetailState> {
  final FetchRoomDateAvailability fetchRoomDateAvailability;

  RoomDetailController({required this.fetchRoomDateAvailability}) 
      : super(RoomDetailState());

  Future<void> loadAvailability(String roomId, String date) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await fetchRoomDateAvailability(roomId: roomId, date: date);
      state = state.copyWith(availability: result, isLoading: false);
    } catch (e) {
      // Aquí mapeamos el error de internet o API
      String errorMessage = "Sucedió un error inesperado";
      if (e.toString().contains('SocketException') || e.toString().contains('Connection failed')) {
        errorMessage = "No internet connection. Please check your network.";
      } else {
        errorMessage = e.toString();
      }
      
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }
}