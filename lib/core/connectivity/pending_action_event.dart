import 'pending_action.dart';

sealed class PendingActionEvent {
  final PendingAction action;
  const PendingActionEvent(this.action);
}

class PendingActionSucceeded extends PendingActionEvent {
  const PendingActionSucceeded(super.action);
}

class PendingActionFailed extends PendingActionEvent {
  final String error;
  const PendingActionFailed(super.action, this.error);
}
