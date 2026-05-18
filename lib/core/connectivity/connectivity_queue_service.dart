import 'dart:async';

import 'package:dio/dio.dart';

import '../error/dio_error_mapper.dart';
import 'pending_action.dart';
import 'pending_action_event.dart';

class ConnectivityQueueService {
  final _queue = <PendingAction>[];
  final _events = StreamController<PendingActionEvent>.broadcast();
  final _batchEvents = StreamController<List<PendingActionEvent>>.broadcast();
  StreamSubscription? _sub;

  Stream<PendingActionEvent> get events => _events.stream;
  Stream<List<PendingActionEvent>> get batchEvents => _batchEvents.stream;

  void init(Stream<void> onRecovered) {
    _sub = onRecovered.listen((_) => _flush());
  }

  void enqueue(PendingAction action) {
    _queue.add(action);
  }

  Future<void> _flush() async {
    final toProcess = List<PendingAction>.from(_queue);
    _queue.clear();
    final batch = <PendingActionEvent>[];

    for (final action in toProcess) {
      try {
        await action.execute();
        final event = PendingActionSucceeded(action);
        batch.add(event);
        _events.add(event);
      } catch (e) {
        if (_isConnectivityError(e)) {
          _queue.insert(0, action);
        } else {
          final event = PendingActionFailed(action, DioErrorMapper.map(e));
          batch.add(event);
          _events.add(event);
        }
      }
    }

    if (batch.isNotEmpty) {
      _batchEvents.add(List.unmodifiable(batch));
    }
  }

  bool _isConnectivityError(Object e) =>
      e is DioException && e.response == null;

  void dispose() {
    _sub?.cancel();
    _events.close();
    _batchEvents.close();
  }
}
