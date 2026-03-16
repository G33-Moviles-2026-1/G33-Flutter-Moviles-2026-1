import '../../../rooms/domain/entities/time_range.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_purpose.dart';

class CreateBookingState {
  final DateTime selectedDate;
  final List<TimeRange> availableTimeRanges;
  final TimeRange? selectedTimeRange;
  final BookingPurpose selectedPurpose;
  final bool isSubmitting;
  final bool isLoadingAvailability;
  final String? errorMessage;
  final String? availabilityErrorMessage;
  final Booking? created;

  const CreateBookingState({
    required this.selectedDate,
    required this.availableTimeRanges,
    required this.selectedTimeRange,
    required this.selectedPurpose,
    required this.isSubmitting,
    required this.isLoadingAvailability,
    required this.errorMessage,
    required this.availabilityErrorMessage,
    required this.created,
  });

  factory CreateBookingState.initial(DateTime today) {
    final normalized = DateTime(today.year, today.month, today.day);
    return CreateBookingState(
      selectedDate: normalized,
      availableTimeRanges: const [],
      selectedTimeRange: null,
      selectedPurpose: BookingPurpose.studyAlone,
      isSubmitting: false,
      isLoadingAvailability: true,
      errorMessage: null,
      availabilityErrorMessage: null,
      created: null,
    );
  }

  CreateBookingState copyWith({
    DateTime? selectedDate,
    List<TimeRange>? availableTimeRanges,
    TimeRange? selectedTimeRange,
    bool clearSelectedTimeRange = false,
    BookingPurpose? selectedPurpose,
    bool? isSubmitting,
    bool? isLoadingAvailability,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? availabilityErrorMessage,
    bool clearAvailabilityErrorMessage = false,
    Booking? created,
    bool clearCreated = false,
  }) {
    return CreateBookingState(
      selectedDate: selectedDate ?? this.selectedDate,
      availableTimeRanges: availableTimeRanges ?? this.availableTimeRanges,
      selectedTimeRange: clearSelectedTimeRange
          ? null
          : (selectedTimeRange ?? this.selectedTimeRange),
      selectedPurpose: selectedPurpose ?? this.selectedPurpose,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoadingAvailability:
          isLoadingAvailability ?? this.isLoadingAvailability,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      availabilityErrorMessage: clearAvailabilityErrorMessage
          ? null
          : (availabilityErrorMessage ?? this.availabilityErrorMessage),
      created: clearCreated ? null : (created ?? this.created),
    );
  }
}