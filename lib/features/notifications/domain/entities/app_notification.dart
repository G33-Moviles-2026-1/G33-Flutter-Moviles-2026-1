class AppNotification {
  final String id;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });
}
