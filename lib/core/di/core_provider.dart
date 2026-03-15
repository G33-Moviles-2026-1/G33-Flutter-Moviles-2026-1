import 'package:andespace/core/analytics/analytics_service.dart';
import 'package:andespace/core/session/session_controller.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/network_constants.dart';

final cookieJarProvider = Provider<CookieJar>((ref) {
  return CookieJar();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: NetworkConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    CookieManager(ref.read(cookieJarProvider)),
  );

  return dio;
});

final sessionControllerProvider = Provider<SessionController>((ref) {
  return SessionController();
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.read(dioProvider));
});
