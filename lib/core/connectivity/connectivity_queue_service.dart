import 'dart:async';

import 'package:dio/dio.dart';

import 'pending_action.dart';
import 'pending_action_event.dart';

class ConnectivityQueueService {
  final _queue = <PendingAction>[];
  final _events = StreamController<PendingActionEvent>.broadcast();
  StreamSubscription? _sub;

  Stream<PendingActionEvent> get events => _events.stream;

  void init(Stream<void> onRecovered) {
    _sub = onRecovered.listen((_) => _flush());
  }

  void enqueue(PendingAction action) {
    _queue.add(action);
  }

  Future<void> _flush() async {
    final toProcess = List<PendingAction>.from(_queue);
    _queue.clear();
    for (final action in toProcess) {
      try {
        await action.execute();
        _events.add(PendingActionSucceeded(action));
      } catch (e) {
        if (_isConnectivityError(e)) {
          _queue.insert(0, action);
        } else {
          _events.add(PendingActionFailed(action, e.toString()));
        }
      }
    }
  }

  bool _isConnectivityError(Object e) =>
      e is DioException && e.response == null;

  void dispose() {
    _sub?.cancel();
    _events.close();
  }
}
