import 'package:andespace/core/di/core_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../rooms/domain/entities/room_search.dart';
import '../../../rooms/domain/entities/time_range.dart';
import '../../domain/entities/booking_purpose.dart';
import '../../domain/usecases/get_booking_availability.dart';
import '../../domain/usecases/get_create_booking_initial_data.dart';
import '../../domain/usecases/submit_booking.dart';
import '../../domain/usecases/validate_booking_date.dart';
import '../providers/bookings_providers.dart';
import 'create_booking_state.dart';

class CreateBookingNotifier
    extends AutoDisposeFamilyNotifier<CreateBookingState, RoomSearchItem> {
  late final GetCreateBookingInitialData _getInitialData;
  late final ValidateBookingDate _validateBookingDate;
  late final GetBookingAvailability _getBookingAvailability;
  late final SubmitBooking _submitBooking;
  late final SessionNotifier _sessionNotifier;

  @override
  CreateBookingState build(RoomSearchItem arg) {
    _getInitialData = ref.read(getCreateBookingInitialDataUseCaseProvider);
    _validateBookingDate = ref.read(validateBookingDateUseCaseProvider);
    _getBookingAvailability = ref.read(getBookingAvailabilityUseCaseProvider);
    _submitBooking = ref.read(submitBookingUseCaseProvider);
    _sessionNotifier = ref.read(sessionControllerProvider.notifier);

    final initialData = _getInitialData(_sessionNotifier);

    Future.microtask(() {
      loadAvailabilityFor(
        initialData.initialDate,
        preferredTimeRange: initialData.preferredTimeRange,
      );
    });

    return CreateBookingState.initial(initialData.initialDate);
  }

  RoomSearchItem get _room => arg;

  Future<void> setDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final validationError = _validateBookingDate(normalized);

    if (validationError != null) {
      state = state.copyWith(
        errorMessage: validationError,
        clearCreated: true,
      );
      return;
    }

    state = state.copyWith(
      selectedDate: normalized,
      clearErrorMessage: true,
      clearCreated: true,
    );

    await loadAvailabilityFor(normalized);
  }

  void setTimeRange(TimeRange? range) {
    state = state.copyWith(
      selectedTimeRange: range,
      clearErrorMessage: true,
      clearCreated: true,
    );
  }

  void setPurpose(BookingPurpose purpose) {
    state = state.copyWith(
      selectedPurpose: purpose,
      clearErrorMessage: true,
      clearCreated: true,
    );
  }

  Future<void> submit() async {
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearCreated: true,
    );

    try {
      final booking = await _submitBooking(
        room: _room,
        selectedDate: state.selectedDate,
        selectedTimeRange: state.selectedTimeRange,
        selectedPurpose: state.selectedPurpose,
        isLoadingAvailability: state.isLoadingAvailability,
        sessionNotifier: _sessionNotifier,
      );

      state = state.copyWith(
        isSubmitting: false,
        created: booking,
      );
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
        clearCreated: true,
      );
    }
  }

  Future<void> loadAvailabilityFor(
    DateTime date, {
    TimeRange? preferredTimeRange,
  }) async {
    state = state.copyWith(
      isLoadingAvailability: true,
      availableTimeRanges: const [],
      clearSelectedTimeRange: true,
      clearAvailabilityErrorMessage: true,
      clearErrorMessage: true,
      clearCreated: true,
    );

    try {
      final data = await _getBookingAvailability(
        roomId: _room.roomId,
        date: date,
        preferredTimeRange: preferredTimeRange,
      );

      state = state.copyWith(
        isLoadingAvailability: false,
        availableTimeRanges: data.availableTimeRanges,
        selectedTimeRange: data.selectedTimeRange,
        clearSelectedTimeRange: data.availableTimeRanges.isEmpty,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingAvailability: false,
        availabilityErrorMessage: error.toString().replaceFirst('Exception: ', ''),
        availableTimeRanges: const [],
        clearSelectedTimeRange: true,
      );
    }
  }
}

final createBookingControllerProvider = NotifierProvider.autoDispose
    .family<CreateBookingNotifier, CreateBookingState, RoomSearchItem>(
  CreateBookingNotifier.new,
);