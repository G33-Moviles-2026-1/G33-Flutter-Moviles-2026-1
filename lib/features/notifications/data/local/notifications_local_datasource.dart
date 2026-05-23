import 'dart:convert';

import 'package:andespace/core/local/app_database.dart';
import 'package:andespace/features/notifications/domain/entities/app_notification.dart';
import 'package:drift/drift.dart';

class NotificationsLocalDataSource {
  const NotificationsLocalDataSource(this._db);

  final AppDatabase _db;

  Future<List<AppNotification>> getSavedNotifications() async {
    final rows = await _db.getCachedNotifications();
    return rows.map((r) {
      final payload =
          jsonDecode(r.payloadJson) as Map<String, dynamic>? ?? {};
      return AppNotification(
        id: r.id,
        type: r.type,
        payload: payload,
        isRead: r.isRead,
        createdAt: r.createdAt,
      );
    }).toList();
  }

  Future<void> saveNotifications(List<AppNotification> notifications) async {
    final top3 = notifications.take(3).toList();
    final rows = top3
        .map(
          (n) => CachedNotificationsTableCompanion(
            id: Value(n.id),
            type: Value(n.type),
            payloadJson: Value(jsonEncode(n.payload)),
            isRead: Value(n.isRead),
            createdAt: Value(n.createdAt),
            savedAt: Value(DateTime.now()),
          ),
        )
        .toList();
    await _db.replaceCachedNotifications(rows);
  }
}
