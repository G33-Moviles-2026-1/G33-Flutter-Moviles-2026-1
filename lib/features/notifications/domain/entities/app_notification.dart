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

  String get friendUsername => payload['friend_username'] as String? ?? '';
  String get roomId => payload['room_id'] as String? ?? '';
  String get bookingDate => payload['date'] as String? ?? '';
  String get startTime =>
      (payload['start_time'] as String? ?? '').substring(0, 5);
  String get endTime => (payload['end_time'] as String? ?? '').substring(0, 5);

  String get fromUsername =>
      (payload['from_username'] ??
          payload['username'] ??
          payload['requester_username'] ??
          '') as String;

  bool get isFriendRequestUpdate =>
      type == 'friend_request_accepted' || type == 'friend_request_rejected';

  String get displayMessage {
    if (type == 'friend_booking' && friendUsername.isNotEmpty) {
      if (roomId.isNotEmpty) return '$friendUsername booked $roomId';
      return '$friendUsername made a booking';
    }
    if (type == 'friend_request_accepted') {
      final who = fromUsername.isNotEmpty ? fromUsername : 'Someone';
      return '$who accepted your friend request';
    }
    if (type == 'friend_request_rejected') {
      final who = fromUsername.isNotEmpty ? fromUsername : 'Someone';
      return '$who declined your friend request';
    }
    return 'New notification';
  }

  String get displaySubtitle {
    if (type == 'friend_booking' && bookingDate.isNotEmpty) {
      final timePart =
          startTime.isNotEmpty && endTime.isNotEmpty ? ' · $startTime–$endTime' : '';
      return '$bookingDate$timePart';
    }
    return '';
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
