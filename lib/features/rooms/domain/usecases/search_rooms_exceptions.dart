class SearchRoomsConnectivityException implements Exception {
  const SearchRoomsConnectivityException();
}

class SearchRoomsOfflinePaginationException implements Exception {
  const SearchRoomsOfflinePaginationException(this.message);

  final String message;

  @override
  String toString() => message;
}