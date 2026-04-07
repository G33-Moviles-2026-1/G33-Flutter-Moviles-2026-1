import 'package:dio/dio.dart';

import '../models/free_rooms_for_day_model.dart';
import '../models/manual_class_model.dart';
import '../models/schedule_class_model.dart';
import '../models/schedule_delete_response_model.dart';
import '../models/schedule_upload_response_model.dart';
import '../models/weekly_schedule_model.dart';

abstract class ScheduleRemoteDataSource {
  Future<ScheduleUploadResponseModel> uploadIcsSchedule({
    required String userEmail,
    required String filePath,
  });

  Future<ScheduleUploadResponseModel> uploadManualSchedule({
    required String userEmail,
    required List<ManualClassModel> classes,
  });

  Future<WeeklyScheduleModel> getWeeklySchedule({
    required String userEmail,
    required DateTime date,
  });

  Future<List<ScheduleClassModel>> getScheduleClasses({
    required String userEmail,
  });

  Future<FreeRoomsForDayModel> getFreeRoomsForDay({
    required String userEmail,
    required DateTime date,
  });

  Future<ScheduleDeleteResponseModel> deleteFullSchedule({
    required String userEmail,
  });

  Future<ScheduleDeleteResponseModel> deleteScheduleClass({
    required String userEmail,
    required String classId,
  });

  Future<ScheduleDeleteResponseModel> deleteScheduleOccurrence({
    required String userEmail,
    required String classId,
    required DateTime date,
  });

  Future<Map<String, dynamic>> getRecommendedRoomsForDay({
    required DateTime date,
  });
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final Dio dio;

  const ScheduleRemoteDataSourceImpl({
    required this.dio,
  });

  @override
  Future<ScheduleUploadResponseModel> uploadIcsSchedule({
    required String userEmail,
    required String filePath,
  }) async {
    final fileName = filePath.split('/').last;

    final formData = FormData.fromMap({
      'user_email': userEmail,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    final response = await dio.post(
      '/schedule/upload/ics',
      data: formData,
    );

    return ScheduleUploadResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ScheduleUploadResponseModel> uploadManualSchedule({
    required String userEmail,
    required List<ManualClassModel> classes,
  }) async {
    final response = await dio.post(
      '/schedule/upload/manual',
      data: {
        'user_email': userEmail,
        'classes': classes.map((e) => e.toJson()).toList(),
      },
    );

    return ScheduleUploadResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<WeeklyScheduleModel> getWeeklySchedule({
    required String userEmail,
    required DateTime date,
  }) async {
    final response = await dio.get(
      '/schedule/week',
      queryParameters: {
        'user_email': userEmail,
        'date': _formatDdMmYyyy(date),
      },
    );

    return WeeklyScheduleModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<List<ScheduleClassModel>> getScheduleClasses({
    required String userEmail,
  }) async {
    final response = await dio.get(
      '/schedule/classes',
      queryParameters: {
        'user_email': userEmail,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final classes = data['classes'] as List<dynamic>? ?? [];

    return classes
        .map((e) => ScheduleClassModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FreeRoomsForDayModel> getFreeRoomsForDay({
    required String userEmail,
    required DateTime date,
  }) async {
    final response = await dio.get(
      '/schedule/free-rooms',
      queryParameters: {
        'user_email': userEmail,
        'date': _formatDdMmYyyy(date),
      },
    );

    return FreeRoomsForDayModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ScheduleDeleteResponseModel> deleteFullSchedule({
    required String userEmail,
  }) async {
    final response = await dio.delete(
      '/schedule',
      queryParameters: {
        'user_email': userEmail,
      },
    );

    return ScheduleDeleteResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ScheduleDeleteResponseModel> deleteScheduleClass({
    required String userEmail,
    required String classId,
  }) async {
    final response = await dio.delete(
      '/schedule/class/$classId',
      queryParameters: {
        'user_email': userEmail,
      },
    );

    return ScheduleDeleteResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ScheduleDeleteResponseModel> deleteScheduleOccurrence({
    required String userEmail,
    required String classId,
    required DateTime date,
  }) async {
    final response = await dio.delete(
      '/schedule/class/$classId/occurrence',
      queryParameters: {
        'user_email': userEmail,
        'date': _formatDdMmYyyy(date),
      },
    );

    return ScheduleDeleteResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  String _formatDdMmYyyy(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$dd-$mm-$yyyy';
  }

  String _formatYyyyMmDd(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$yyyy-$mm-$dd';
  }

  @override
  Future<Map<String, dynamic>> getRecommendedRoomsForDay({
    required DateTime date,
  }) async {
    final response = await dio.get(
      '/schedule/recommendations/day',
      queryParameters: {
        'date': _formatYyyyMmDd(date),
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw const FormatException('Invalid recommendations response format.');
  }
}