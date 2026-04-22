import 'room_search.dart';
import 'room_search_source.dart';

class RoomSearchResult {
  const RoomSearchResult({
    required this.response,
    required this.source,
    this.message,
  });

  final RoomSearchResponse response;
  final RoomSearchSource source;
  final String? message;
}