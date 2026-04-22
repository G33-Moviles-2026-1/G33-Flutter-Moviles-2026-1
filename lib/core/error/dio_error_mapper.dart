import 'package:dio/dio.dart';

class DioErrorMapper {
  const DioErrorMapper._();

  static const String _defaultFallback =
      'Something went wrong. Please try again.';
  static const String _serverNotResponding =
      'The server is not responding. Please try again later.';
  static const String _noInternetConnection =
      'No internet connection. Please check your connection and try again.';
  static const String _secureConnectionFailed =
      'A secure connection could not be established. Please try again later.';
  static const String _requestCancelled =
      'The request was cancelled. Please try again.';
  static const String _serverUnavailable =
      'The server is currently unavailable. Please try again later.';

  static String map(
    Object error, {
    String fallback = _defaultFallback,
    String Function(int statusCode, String? detail)? onBadResponse,
  }) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return _serverNotResponding;

        case DioExceptionType.connectionError:
          return _noInternetConnection;

        case DioExceptionType.badCertificate:
          return _secureConnectionFailed;

        case DioExceptionType.cancel:
          return _requestCancelled;

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          final detail = _extractDetail(data);

          if (statusCode != null && statusCode >= 500) {
            return _serverUnavailable;
          }

          if (statusCode != null && onBadResponse != null) {
            return onBadResponse(statusCode, detail);
          }

          return detail ?? fallback;

        case DioExceptionType.unknown:
          final msg = error.message?.toLowerCase() ?? '';
          if (_isNetworkKeyword(msg)) {
            return _noInternetConnection;
          }
          if (msg.contains('timeout')) {
            return _serverNotResponding;
          }
          return fallback;
      }
    }

    final raw = error.toString().toLowerCase();
    if (_isNetworkKeyword(raw)) {
      return _noInternetConnection;
    }
    if (raw.contains('timeout')) {
      return _serverNotResponding;
    }

    return fallback;
  }

  static String? _extractDetail(Object? data) {
    final rawDetail = data is Map ? data['detail'] : null;

    if (rawDetail is String) {
      return rawDetail;
    }

    if (rawDetail is List) {
      return rawDetail
          .map((e) => e is Map ? (e['msg'] ?? e.toString()) : e.toString())
          .join(', ');
    }

    return null;
  }

  static bool _isNetworkKeyword(String msg) =>
      msg.contains('socketexception') ||
      msg.contains('failed host lookup') ||
      msg.contains('network is unreachable');
}