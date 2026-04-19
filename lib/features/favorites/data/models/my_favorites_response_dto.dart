class MyFavoritesResponseDto {
  const MyFavoritesResponseDto({
    required this.total,
    required this.roomIds,
  });

  final int total;
  final List<String> roomIds;

  factory MyFavoritesResponseDto.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? const [])
        .map((e) => (e as Map<String, dynamic>)['room_id'] as String)
        .toList();

    return MyFavoritesResponseDto(
      total: json['total'] as int? ?? items.length,
      roomIds: items,
    );
  }
}