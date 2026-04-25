import '../entities/weekly_schedule.dart';
import '../repositories/schedule_repository.dart';

class LoadWeekForCurrentUserUseCase {
  final ScheduleRepository repository;

  LoadWeekForCurrentUserUseCase({
    required this.repository,
  });

  Future<WeeklySchedule> call({required DateTime date}) async {

    return repository.getWeeklySchedule(
      date: date,
    );
  }
}