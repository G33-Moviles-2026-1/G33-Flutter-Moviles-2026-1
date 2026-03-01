import '../../domain/entities/room_detail.dart';

abstract class RoomDetailState {
  const RoomDetailState();
}

class RoomDetailInitial extends RoomDetailState {
  const RoomDetailInitial();
}

class RoomDetailLoading extends RoomDetailState {
  const RoomDetailLoading();
}

class RoomDetailLoaded extends RoomDetailState {
  final RoomDetail roomDetail;

  const RoomDetailLoaded(this.roomDetail);
}

class RoomDetailError extends RoomDetailState {
  final String message;

  const RoomDetailError(this.message);
}