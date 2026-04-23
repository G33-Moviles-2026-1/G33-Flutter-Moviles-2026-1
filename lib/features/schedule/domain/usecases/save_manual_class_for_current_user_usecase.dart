import '../entities/manual_class.dart';
import '../entities/schedule_class.dart';
import '../repositories/schedule_repository.dart';
import 'get_authenticated_user_email_usecase.dart';
import 'get_schedule_classes_for_current_user_usecase.dart';

class SaveManualClassForCurrentUserUseCase {
  final ScheduleRepository repository;
  final GetAuthenticatedUserEmailUseCase getAuthenticatedUserEmail;
  final GetScheduleClassesForCurrentUserUseCase getScheduleClassesForCurrentUser;

  SaveManualClassForCurrentUserUseCase({
    required this.repository,
    required this.getAuthenticatedUserEmail,
    required this.getScheduleClassesForCurrentUser,
  });

  Future<void> call({required ManualClass manualClass}) async {
    final userEmail = await getAuthenticatedUserEmail();
    final existingClasses = await getScheduleClassesForCurrentUser();

    final allClasses = [
      ...existingClasses.map(_toManualClass),
      manualClass,
    ];

    await repository.uploadManualSchedule(
      userEmail: userEmail,
      classes: allClasses,
    );
  }

  ManualClass _toManualClass(ScheduleClass scheduleClass) {
    return ManualClass(
      title: scheduleClass.title ?? 'Class',
      locationText: scheduleClass.locationText,
      roomId: scheduleClass.roomId,
      startDate: scheduleClass.startDate,
      endDate: scheduleClass.endDate,
      startTime: scheduleClass.startTime,
      endTime: scheduleClass.endTime,
      weekdays: scheduleClass.weekdays,
    );
  }
}