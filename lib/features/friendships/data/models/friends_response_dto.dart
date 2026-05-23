import 'friend_dto.dart';

class FriendsResponseDto {
  const FriendsResponseDto({
    required this.total,
    required this.items,
  });

  final int total;
  final List<FriendDto> items;

  factory FriendsResponseDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];

    return FriendsResponseDto(
      total: (json['total'] as num?)?.toInt() ?? rawItems.length,
      items: rawItems
          .map((e) => FriendDto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}