import 'package:andespace/features/rooms/domain/entities/room_search.dart';

import '../repositories/schedule_repository.dart';
import 'get_authenticated_user_email_usecase.dart';

class GetRecommendedRoomsForCurrentUserUseCase {
  final ScheduleRepository repository;
  final GetAuthenticatedUserEmailUseCase getAuthenticatedUserEmail;

  GetRecommendedRoomsForCurrentUserUseCase({
    required this.repository,
    required this.getAuthenticatedUserEmail,
  });

  Future<List<RoomSearchItem>> call({required DateTime date}) async {
    final userEmail = await getAuthenticatedUserEmail();

    return repository.getRecommendedRoomsForDay(
      userEmail: userEmail,
      date: date,
    );
  }
}