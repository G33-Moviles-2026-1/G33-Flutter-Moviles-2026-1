import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SessionLocation {
  const SessionLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}


class SessionController extends ChangeNotifier {
  SessionController({
    SessionLocation? debugLocation,
  }) : _currentLocation = debugLocation;

  final String sessionId = _generateUuidLike();
  final String deviceId = 'flutter-debug-device';

  SessionLocation? _currentLocation;
  SessionLocation? get currentLocation => _currentLocation;

  Future<void> refreshLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );

    _currentLocation = SessionLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    
    notifyListeners();
  }

  static String _generateUuidLike() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));

    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String hex(int value) => value.toRadixString(16).padLeft(2, '0');
    final raw = bytes.map(hex).join();

    return '${raw.substring(0, 8)}-'
        '${raw.substring(8, 12)}-'
        '${raw.substring(12, 16)}-'
        '${raw.substring(16, 20)}-'
        '${raw.substring(20, 32)}';
  }
}