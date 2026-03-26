import '../entities/schedule_class.dart';
import '../repositories/schedule_repository.dart';

class GetScheduleClasses {
  final ScheduleRepository repository;

  const GetScheduleClasses(this.repository);

  Future<List<ScheduleClass>> call({
    required String userEmail,
  }) {
    return repository.getScheduleClasses(
      userEmail: userEmail,
    );
  }
}