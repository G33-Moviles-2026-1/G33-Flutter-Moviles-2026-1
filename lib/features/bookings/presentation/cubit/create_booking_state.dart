import '../../../rooms/domain/entities/time_range.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_purpose.dart';

class CreateBookingState {
  final DateTime selectedDate;
  final TimeRange? selectedTimeRange;
  final BookingPurpose selectedPurpose;
  final int peopleCount;

  final bool isSubmitting;
  final String? errorMessage;
  final Booking? created;

  const CreateBookingState({
    required this.selectedDate,
    required this.selectedTimeRange,
    required this.selectedPurpose,
    required this.peopleCount,
    required this.isSubmitting,
    required this.errorMessage,
    required this.created,
  });

  factory CreateBookingState.initial() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return CreateBookingState(
      selectedDate: today,
      selectedTimeRange: null,
      selectedPurpose: BookingPurpose.studyAlone,
      peopleCount: 1,
      isSubmitting: false,
      errorMessage: null,
      created: null,
    );
  }

  CreateBookingState copyWith({
    DateTime? selectedDate,
    TimeRange? selectedTimeRange,
    BookingPurpose? selectedPurpose,
    int? peopleCount,
    bool? isSubmitting,
    String? errorMessage, // pass null explicitly to clear
    Booking? created,      // pass null explicitly to clear
  }) {
    return CreateBookingState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeRange: selectedTimeRange ?? this.selectedTimeRange,
      selectedPurpose: selectedPurpose ?? this.selectedPurpose,
      peopleCount: peopleCount ?? this.peopleCount,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      created: created,
    );
  }
}