import 'package:dio/dio.dart';

String mapGoogleCalendarImportErrorMessage(Object error) {
  if (error is DioException) {
    final detail = _extractDioDetail(error.response?.data);

    if (error.response?.statusCode == 503 &&
        detail?.toLowerCase().contains('google calendar is not configured') ==
            true) {
      return 'Google Calendar is not configured on the server.';
    }

    if (detail != null && detail.trim().isNotEmpty) {
      return detail;
    }
  }

  return 'Could not import Google Calendar. Please try again.';
}

String? _extractDioDetail(Object? data) {
  final detail = data is Map ? data['detail'] : null;

  if (detail is String) {
    return detail;
  }

  if (detail is List) {
    return detail
        .map((e) => e is Map ? (e['msg'] ?? e.toString()) : e.toString())
        .join(', ');
  }

  return null;
}
