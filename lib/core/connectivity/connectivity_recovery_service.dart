import 'dart:async';
import 'dart:io';

class ConnectivityRecoveryService {
  final _controller = StreamController<void>.broadcast();
  StreamSubscription? _sub;
  bool _wasOffline = false;
  bool _started = false;

  Stream<void> get onRecovered => _controller.stream;

  void startMonitoring() {
    if (_started) return;
    _started = true;
    _sub = Stream.periodic(const Duration(seconds: 3))
        .asyncMap((_) => _isOnline())
        .listen((online) {
      if (_wasOffline && online) _controller.add(null);
      _wasOffline = !online;
    });
  }

  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
