import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics_service.dart';
import '../network/dio_provider.dart';
import '../session/session_controller.dart';

final sessionControllerProvider = Provider<SessionController>((ref) {
  return SessionController();
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.read(dioProvider));
});