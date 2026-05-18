import '../../domain/entities/room_recommendation.dart';

class AutoSearchRoomsRequestDto {
  const AutoSearchRoomsRequestDto(this.request);

  final AutoSearchRoomsRequest request;

  Map<String, dynamic> toJson() {
    return {
      'target_date': request.targetDate,
      'target_time': request.targetTime,
      'top_k': request.topK,
      'exclude_ids': request.excludeIds,
    };
  }
}
