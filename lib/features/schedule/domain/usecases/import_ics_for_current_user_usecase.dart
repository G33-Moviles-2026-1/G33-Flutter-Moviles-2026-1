import '../repositories/schedule_repository.dart';

class ImportIcsForCurrentUserUseCase {
  final ScheduleRepository repository;

  ImportIcsForCurrentUserUseCase({
    required this.repository,
  });

  Future<void> call({required String filePath}) async {

    await repository.uploadIcsSchedule(
      filePath: filePath,
    );
  }
}