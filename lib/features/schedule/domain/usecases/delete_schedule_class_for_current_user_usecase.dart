import '../repositories/schedule_repository.dart';
class DeleteScheduleClassForCurrentUserUseCase {
  final ScheduleRepository repository;

  DeleteScheduleClassForCurrentUserUseCase({
    required this.repository,
  });

  Future<void> call({required String classId}) async {
    await repository.deleteScheduleClass(
      classId: classId,
    );
  }
}