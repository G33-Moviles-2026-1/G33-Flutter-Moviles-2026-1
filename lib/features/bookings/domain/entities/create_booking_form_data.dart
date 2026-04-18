import '../../../rooms/domain/entities/time_range.dart';

class CreateBookingFormData {
  final DateTime initialDate;
  final TimeRange? preferredTimeRange;

  const CreateBookingFormData({
    required this.initialDate,
    required this.preferredTimeRange,
  });
}