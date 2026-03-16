import '../../domain/entities/my_booking.dart';

class MyBookingsState {
  final bool isLoading;
  final List<MyBooking> items;
  final Set<String> deletingIds;
  final String? errorMessage;

  const MyBookingsState({
    this.isLoading = false,
    this.items = const [],
    this.deletingIds = const {},
    this.errorMessage,
  });

  MyBookingsState copyWith({
    bool? isLoading,
    List<MyBooking>? items,
    Set<String>? deletingIds,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return MyBookingsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      deletingIds: deletingIds ?? this.deletingIds,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}