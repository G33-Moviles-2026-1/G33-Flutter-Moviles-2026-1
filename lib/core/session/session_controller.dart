import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class SessionLocation {
  const SessionLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class UserSearchSelection {
  final DateTime date;
  final String? startTime;
  final String? endTime;

  UserSearchSelection({required this.date, this.startTime, this.endTime});
}

class SessionState {
  final UserSearchSelection? currentSearch;
  final SessionLocation? currentLocation;

  const SessionState({this.currentSearch, this.currentLocation});

  SessionState copyWith({
    UserSearchSelection? currentSearch,
    SessionLocation? currentLocation,
  }) => SessionState(
    currentSearch: currentSearch ?? this.currentSearch,
    currentLocation: currentLocation ?? this.currentLocation,
  );
}

class SessionNotifier extends Notifier<SessionState> {
  final String sessionId = _generateUuidLike();
  final String deviceId = 'flutter-debug-device';

  @override
  SessionState build() {
    final now = DateTime.now();
    return SessionState(
      currentSearch: UserSearchSelection(
        date: DateTime(now.year, now.month, now.day),
      ),
    );
  }

  UserSearchSelection? get currentSearch => state.currentSearch;
  SessionLocation? get currentLocation => state.currentLocation;

  void updateSearchSelection({
    required DateTime date,
    String? startTime,
    String? endTime,
  }) {
    state = state.copyWith(
      currentSearch: UserSearchSelection(
        date: date,
        startTime: startTime,
        endTime: endTime,
      ),
    );
  }

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
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    state = state.copyWith(
      currentLocation: SessionLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
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
