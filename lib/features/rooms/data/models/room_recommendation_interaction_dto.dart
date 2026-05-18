import '../../domain/entities/room_recommendation.dart';

class RoomRecommendationInteractionDto {
  const RoomRecommendationInteractionDto(this.interaction);

  final RoomRecommendationInteraction interaction;

  Map<String, dynamic> toJson() {
    return {
      'room_id': interaction.roomId,
      'action': interaction.action.apiValue,
      'weekday': interaction.weekday,
      'slot_start': interaction.slotStart,
    };
  }
}
