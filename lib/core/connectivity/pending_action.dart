abstract class PendingAction {
  String get successMessage;
  String get failureMessage;
  Future<void> execute();
}
