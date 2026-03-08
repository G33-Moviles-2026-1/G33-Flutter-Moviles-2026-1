import 'package:andespace/features/rooms/domain/repositories/rooms_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'room_detail_state.dart';

class RoomDetailCubit extends Cubit<RoomDetailState> {
  final RoomRepository repository;

  RoomDetailCubit(this.repository)
      : super(const RoomDetailInitial());

  Future<void> fetchRoomDetail(String roomId) async {
    emit(const RoomDetailLoading());

    try {
      final roomDetail = await repository.getRoomDetail(roomId);
      emit(RoomDetailLoaded(roomDetail));
    } catch (e) {
      emit(RoomDetailError(e.toString()));
    }
  }
}
