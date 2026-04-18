import 'package:dio/dio.dart';

class DioErrorMapper {
  const DioErrorMapper._();
  static String map(
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
    String Function(int statusCode, String? detail)? onBadResponse,
  }) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'The server is not responding. Please try again later.';

        case DioExceptionType.connectionError:
          return 'No internet connection. Please check your connection and try again.';

        case DioExceptionType.badCertificate:
          return 'A secure connection could not be established. Please try again later.';

        case DioExceptionType.cancel:
          return 'The request was cancelled. Please try again.';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          final detail = data is Map ? data['detail'] as String? : null;

          if (statusCode != null && statusCode >= 500) {
            return 'The server is currently unavailable. Please try again later.';
          }

          if (statusCode != null && onBadResponse != null) {
            return onBadResponse(statusCode, detail);
          }

          return detail ?? fallback;

        case DioExceptionType.unknown:
          final msg = error.message?.toLowerCase() ?? '';
          if (_isNetworkKeyword(msg)) {
            return 'No internet connection. Please check your connection and try again.';
          }
          if (msg.contains('timeout')) {
            return 'The server is not responding. Please try again later.';
          }
          return fallback;
      }
    }

    final raw = error.toString().toLowerCase();
    if (_isNetworkKeyword(raw)) {
      return 'No internet connection. Please check your connection and try again.';
    }
    if (raw.contains('timeout')) {
      return 'The server is not responding. Please try again later.';
    }

    return fallback;
  }

  static bool _isNetworkKeyword(String msg) =>
      msg.contains('socketexception') ||
      msg.contains('failed host lookup') ||
      msg.contains('network is unreachable');
}
