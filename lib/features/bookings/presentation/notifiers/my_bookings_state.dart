import '../../domain/entities/my_booking.dart';

class MyBookingsState {
  final bool isLoading;
  final List<MyBooking> items;
  final Set<String> deletingIds;
  final String? errorMessage;
  final String? pendingSyncMessage;

  const MyBookingsState({
    this.isLoading = false,
    this.items = const [],
    this.deletingIds = const {},
    this.errorMessage,
    this.pendingSyncMessage,
  });

  MyBookingsState copyWith({
    bool? isLoading,
    List<MyBooking>? items,
    Set<String>? deletingIds,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? pendingSyncMessage,
    bool clearPendingSyncMessage = false,
  }) {
    return MyBookingsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      deletingIds: deletingIds ?? this.deletingIds,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      pendingSyncMessage: clearPendingSyncMessage ? null : (pendingSyncMessage ?? this.pendingSyncMessage),
    );
  }
}