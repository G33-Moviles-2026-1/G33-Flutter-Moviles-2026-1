import 'package:andespace/core/error/dio_error_mapper.dart';

String mapScheduleErrorMessage(Object error) {
  return DioErrorMapper.map(
    error,
    fallback: 'Something went wrong. Please try again.',
    onBadResponse: (statusCode, detail) {
      if (statusCode == 422) {
        final d = detail?.toLowerCase() ?? '';

        if (d.contains('class start_time must be between 05:30 and 22:00') ||
            d.contains('class end_time must be at or before 22:00') ||
            d.contains('class end_time must be later than start_time')) {
          return 'The class hours must be between 05:30 and 22:00.';
        }
      }

      return 'Something went wrong. Please try again.';
    },
  );
}