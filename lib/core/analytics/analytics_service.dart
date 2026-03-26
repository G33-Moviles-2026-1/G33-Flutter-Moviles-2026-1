import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService(this._dio);
  final Dio _dio;

  static const String _eventsPath = '/analytics/events';
  static const String _scheduleImportStepPath = '/analytics/schedule-import-step';

  Future<void> track({
    required String sessionId,
    required String deviceId,
    required String eventName,
    required String screen,
    Map<String, dynamic> propsJson = const {},
    String? userEmail,
    int? durationMs,
  }) async {
    try {
      await _dio.post(
        _eventsPath,
        data: {
          'session_id': sessionId,
          'device_id': deviceId,
          'user_email': userEmail,
          'event_name': eventName,
          'screen': screen,
          'duration_ms': durationMs,
          'props_json': propsJson,
        },
      );
    } catch (e, st) {
      debugPrint('Analytics error: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> trackScheduleImportStep({
    required String sessionId,
    required String deviceId,
    required String method,
    required String step,
    required int stepNumber,
    String? userEmail,
    Map<String, dynamic> propsJson = const {},
  }) async {
    try {
      await _dio.post(
        _scheduleImportStepPath,
        data: {
          'session_id': sessionId,
          'device_id': deviceId,
          'user_email': userEmail,
          'method': method,
          'step': step,
          'step_number': stepNumber,
          'props_json': propsJson,
        },
      );
    } catch (e, st) {
      debugPrint('Schedule funnel analytics error: $e');
      debugPrintStack(stackTrace: st);
    }
  }
}