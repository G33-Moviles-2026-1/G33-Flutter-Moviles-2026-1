import '../../domain/entities/room_search.dart';

enum HomeSearchStatus {
  initial,
  loading,
  success,
  error,
}

class HomeSearchState {
  const HomeSearchState({
    required this.status,
    this.response,
    this.errorMessage,
  });

  const HomeSearchState.initial()
      : status = HomeSearchStatus.initial,
        response = null,
        errorMessage = null;

  const HomeSearchState.loading({
    RoomSearchResponse? previousResponse,
  }) : this(
          status: HomeSearchStatus.loading,
          response: previousResponse,
          errorMessage: null,
        );

  const HomeSearchState.success(RoomSearchResponse response)
      : this(
          status: HomeSearchStatus.success,
          response: response,
          errorMessage: null,
        );

  const HomeSearchState.error(
    String message, {
    RoomSearchResponse? previousResponse,
  }) : this(
          status: HomeSearchStatus.error,
          response: previousResponse,
          errorMessage: message,
        );

  final HomeSearchStatus status;
  final RoomSearchResponse? response;
  final String? errorMessage;

  bool get isLoading => status == HomeSearchStatus.loading;
}