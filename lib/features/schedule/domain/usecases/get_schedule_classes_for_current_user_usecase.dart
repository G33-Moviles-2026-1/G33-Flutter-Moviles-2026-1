import '../entities/schedule_class.dart';
import '../repositories/schedule_repository.dart';

class GetScheduleClassesForCurrentUserUseCase {
  final ScheduleRepository repository;

  GetScheduleClassesForCurrentUserUseCase({
    required this.repository,
  });

  Future<List<ScheduleClass>> call() async {

    return repository.getScheduleClasses();
  }
}