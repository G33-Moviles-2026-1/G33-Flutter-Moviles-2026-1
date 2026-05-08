import '../entities/manual_class.dart';
import '../entities/schedule_class.dart';
import '../repositories/schedule_repository.dart';
import 'get_schedule_classes_for_current_user_usecase.dart';
import 'validate_schedule_class_requirements_usecase.dart';

class SaveManualClassForCurrentUserUseCase {
  final ScheduleRepository repository;
  final GetScheduleClassesForCurrentUserUseCase getScheduleClassesForCurrentUser;
  final ValidateScheduleClassRequirementsUseCase validateScheduleClassRequirements;

  SaveManualClassForCurrentUserUseCase({
    required this.repository,
    required this.getScheduleClassesForCurrentUser,
    required this.validateScheduleClassRequirements,
  });

  Future<void> call({required ManualClass manualClass}) async {
    final existingClasses = await getScheduleClassesForCurrentUser();

    validateScheduleClassRequirements(
      newClasses: [manualClass],
      existingClasses: existingClasses,
    );

    final allClasses = [
      ...existingClasses.map(_toManualClass),
      manualClass,
    ];

    await repository.uploadManualSchedule(classes: allClasses);
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
