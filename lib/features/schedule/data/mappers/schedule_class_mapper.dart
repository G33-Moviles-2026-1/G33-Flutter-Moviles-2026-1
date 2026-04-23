import '../../domain/entities/schedule_class.dart';
import '../models/schedule_class_dto.dart';

class ScheduleClassMapper {
  const ScheduleClassMapper._();

  static ScheduleClass toEntity(ScheduleClassModel model) {
    return ScheduleClass(
      classId: model.classId,
      title: model.title,
      locationText: model.locationText,
      roomId: _normalizeRoomId(
        model.roomId,
        fallback: model.locationText,
      ),
      startDate: model.startDate,
      endDate: model.endDate,
      startTime: model.startTime,
      endTime: model.endTime,
      weekdays: model.weekdays,
    );
  }

  static List<ScheduleClass> toEntityList(List<ScheduleClassModel> models) {
    return models.map(toEntity).toList();
  }

  static String? _normalizeRoomId(String? roomId, {required String? fallback}) {
    if (roomId != null && roomId.trim().isNotEmpty) {
      return roomId;
    }
    return fallback;
  }
}