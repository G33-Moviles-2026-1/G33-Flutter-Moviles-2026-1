import 'package:andespace/core/utils/date_time_utils.dart';

import '../entities/room_date_availability.dart';
import '../repositories/rooms_repository.dart';

class FetchRoomDateAvailability {
  final RoomRepository _repository;

  const FetchRoomDateAvailability(this._repository);

  Future<RoomDateAvailability> call({
    required String roomId,
    required DateTime date,
  }) {
    return _repository.fetchRoomDateAvailability(
      roomId: roomId,
      date: DateTimeUtils.toApiDate(date),
    );
  }
}
