import '../entities/manual_class.dart';
import '../repositories/schedule_repository.dart';

class UploadManualSchedule {
  final ScheduleRepository repository;

  const UploadManualSchedule(this.repository);

  Future<void> call({
    required String userEmail,
    required List<ManualClass> classes,
  }) {
    return repository.uploadManualSchedule(
      userEmail: userEmail,
      classes: classes,
    );
  }
}