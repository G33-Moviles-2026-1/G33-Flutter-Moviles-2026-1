import '../repositories/schedule_repository.dart';

class UploadIcsSchedule {
  final ScheduleRepository repository;

  const UploadIcsSchedule(this.repository);

  Future<void> call({
    required String userEmail,
    required String filePath,
  }) {
    return repository.uploadIcsSchedule(
      userEmail: userEmail,
      filePath: filePath,
    );
  }
}