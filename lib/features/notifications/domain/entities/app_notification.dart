class AppNotification {
  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.payload,
    required this.isRead,
    required this.createdAt,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      payload: payload,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  String get displayMessage {
    if (type == 'friend_booking') {
      final friend = payload['friend_username'] as String?;
      final room = payload['room_name'] as String?;
      if (friend != null && room != null) return '$friend booked $room';
      if (friend != null) return '$friend made a booking';
    }
    return 'New notification';
  }

  static AppNotification fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String? ?? 'unknown',
      payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? {},
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
