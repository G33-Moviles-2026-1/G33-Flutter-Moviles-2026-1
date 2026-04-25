import '../../domain/entities/free_rooms_for_day.dart';
import '../models/free_rooms_for_day_dto.dart';

class FreeRoomsForDayMapper {
  const FreeRoomsForDayMapper._();

  static FreeRoomsForDay toEntity(FreeRoomsForDayModel model) {
    return FreeRoomsForDay(
      date: model.date,
      weekday: model.weekday,
      freeSlots: model.freeSlots
          .map(
            (slot) => FreeSlot(
              startTime: slot.startTime,
              endTime: slot.endTime,
            ),
          )
          .toList(),
      slotsWithRooms: model.slotsWithRooms
          .map(
            (slot) => SlotWithRooms(
              slotStart: slot.slotStart,
              slotEnd: slot.slotEnd,
              availableRooms: slot.availableRooms
                  .map(
                    (room) => RoomInSlot(
                      roomId: room.roomId,
                      buildingName: room.buildingName,
                      capacity: room.capacity,
                      reliability: room.reliability,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}