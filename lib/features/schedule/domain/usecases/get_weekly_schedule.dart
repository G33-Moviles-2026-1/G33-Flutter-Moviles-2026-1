import '../entities/weekly_schedule.dart';
import '../repositories/schedule_repository.dart';

class GetWeeklySchedule {
  final ScheduleRepository repository;

  const GetWeeklySchedule(this.repository);

  Future<WeeklySchedule> call({
    required String userEmail,
    required DateTime date,
  }) {
    return repository.getWeeklySchedule(
      userEmail: userEmail,
      date: date,
    );
  }
}