import 'dart:math';

class SessionLocation {
  const SessionLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

class SessionController {
  SessionController({
    SessionLocation? debugLocation,
  }) : _debugLocation = debugLocation ??
            const SessionLocation(
              latitude: 4.6021,
              longitude: -74.0659,
            );

  final SessionLocation _debugLocation;

  final String sessionId = _generateUuidLike();
  final String deviceId = 'flutter-debug-device';

  // Temporary until real device location is wired.
  SessionLocation? get currentLocation => _debugLocation;

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