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
    this.infoMessage,
  });

  const HomeSearchState.initial()
      : status = HomeSearchStatus.initial,
        response = null,
        errorMessage = null,
        infoMessage = null;

  const HomeSearchState.loading({
    RoomSearchResponse? previousResponse,
  }) : this(
          status: HomeSearchStatus.loading,
          response: previousResponse,
          errorMessage: null,
          infoMessage: null,
        );

  const HomeSearchState.success(
    RoomSearchResponse response, {
    String? infoMessage,
  }) : this(
          status: HomeSearchStatus.success,
          response: response,
          errorMessage: null,
          infoMessage: infoMessage,
        );

  const HomeSearchState.error(
    String message, {
    RoomSearchResponse? previousResponse,
  }) : this(
          status: HomeSearchStatus.error,
          response: previousResponse,
          errorMessage: message,
          infoMessage: null,
        );

  final HomeSearchStatus status;
  final RoomSearchResponse? response;
  final String? errorMessage;
  final String? infoMessage;

  bool get isLoading => status == HomeSearchStatus.loading;

  String? get feedbackMessage => errorMessage ?? infoMessage;
}