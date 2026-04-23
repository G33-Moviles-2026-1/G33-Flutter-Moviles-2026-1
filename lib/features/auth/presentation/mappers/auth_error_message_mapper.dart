import 'package:andespace/core/error/dio_error_mapper.dart';

String mapAuthErrorMessage(
  Object error, {
  required String fallbackMessage,
}) {
  return DioErrorMapper.map(
    error,
    fallback: fallbackMessage,
    onBadResponse: (statusCode, detail) {
      if (statusCode == 400 && detail == 'User already registered') {
        return 'This user already exists.';
      }

      if (statusCode == 401 || statusCode == 403) {
        return 'Incorrect email or password.';
      }

      return fallbackMessage;
    },
  );
}