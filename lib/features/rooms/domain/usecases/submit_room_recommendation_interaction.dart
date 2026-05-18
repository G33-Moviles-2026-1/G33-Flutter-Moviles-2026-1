import '../entities/room_recommendation.dart';
import '../repositories/rooms_repository.dart';

class SubmitRoomRecommendationInteraction {
  const SubmitRoomRecommendationInteraction(this._repository);

  final RoomRepository _repository;

  Future<void> call(RoomRecommendationInteraction interaction) {
    return _repository.submitRecommendationInteraction(interaction);
  }
}
