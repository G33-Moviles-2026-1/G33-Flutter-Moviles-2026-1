import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../../rooms/domain/entities/room_detail.dart';
import '../../../rooms/domain/entities/time_range.dart';
import '../../../rooms/domain/entities/room_detail.dart' show Weekday;
import '../../domain/entities/booking_purpose.dart';
import '../../domain/usecases/create_booking.dart';
import 'create_booking_state.dart';

class CreateBookingCubit extends Cubit<CreateBookingState> {
  CreateBookingCubit({
    required this.roomDetail,
    required CreateBooking createBooking,
  })  : _createBooking = createBooking,
        super(CreateBookingState.initial()) {
    // Set initial time range from today's weekday (if any)
    final ranges = currentAvailabilities();
    if (ranges.isNotEmpty) {
      emit(state.copyWith(selectedTimeRange: ranges.first, errorMessage: null, created: null));
    }
  }

  final RoomDetail roomDetail;
  final CreateBooking _createBooking;

  // --- Availability helpers ---

  Weekday _mapDateToWeekday(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return Weekday.monday;
      case DateTime.tuesday:
        return Weekday.tuesday;
      case DateTime.wednesday:
        return Weekday.wednesday;
      case DateTime.thursday:
        return Weekday.thursday;
      case DateTime.friday:
        return Weekday.friday;
      case DateTime.saturday:
        return Weekday.saturday;
      case DateTime.sunday:
      default:
        return Weekday.sunday;
    }
  }

  List<TimeRange> currentAvailabilities() {
    final w = _mapDateToWeekday(state.selectedDate);
    return roomDetail.gapsFor(w);
  }

  // --- Setters ---

  void setDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final nextAvail = roomDetail.gapsFor(_mapDateToWeekday(d));

    emit(state.copyWith(
      selectedDate: d,
      selectedTimeRange: nextAvail.isNotEmpty ? nextAvail.first : null,
      errorMessage: null,
      created: null,
    ));
  }

  void setTimeRange(TimeRange? range) {
    emit(state.copyWith(selectedTimeRange: range, errorMessage: null, created: null));
  }

  void setPurpose(BookingPurpose purpose) {
    emit(state.copyWith(selectedPurpose: purpose, errorMessage: null, created: null));
  }

  void setPeopleCount(int count) {
    final capped = count.clamp(1, roomDetail.capacity);
    emit(state.copyWith(peopleCount: capped, errorMessage: null, created: null));
  }

  // --- Submit ---

  Future<void> submit() async {
    if (state.selectedTimeRange == null) {
      emit(state.copyWith(errorMessage: 'Please select a time slot.', created: null));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null, created: null));

    try {
      final booking = await _createBooking(
        roomId: roomDetail.id,
        date: state.selectedDate,
        timeRange: state.selectedTimeRange!,
        purpose: state.selectedPurpose,
        peopleCount: state.peopleCount,
        roomCapacity: roomDetail.capacity,
      );

      emit(state.copyWith(isSubmitting: false, errorMessage: null, created: booking));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString(), created: null));
    }
  }
}