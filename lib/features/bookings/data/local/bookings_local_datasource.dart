import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/my_booking_dto.dart';

class BookingsLocalDataSource {
  static const _boxName = 'my_bookings';
  static const _key = 'items';

  final Box _box;

  const BookingsLocalDataSource(this._box);

  static Future<BookingsLocalDataSource> open() async {
    final box = await Hive.openBox(_boxName);
    return BookingsLocalDataSource(box);
  }

  List<MyBookingDto> getBookings() {
    final raw = _box.get(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw as String) as List<dynamic>;
    return list
        .map((e) => MyBookingDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> saveBookings(List<MyBookingDto> dtos) async {
    final encoded = jsonEncode(dtos.map((d) => d.toJson()).toList());
    await _box.put(_key, encoded);
  }

  Future<void> removeBooking(String bookingId) async {
    final current = getBookings();
    final updated = current.where((d) => d.id != bookingId).toList();
    await saveBookings(updated);
  }

  Future<void> clear() => _box.delete(_key);
}