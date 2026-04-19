import 'package:andespace/core/analytics/analytics_service.dart';
import 'package:andespace/core/session/session_controller.dart';
export 'package:andespace/core/session/session_controller.dart'
    show SessionNotifier, SessionState, SessionLocation, UserSearchSelection;
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
      baseUrl: _validatedBaseUrl(NetworkConstants.baseUrl),
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

final sessionControllerProvider =
    NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.read(dioProvider));
});

String _validatedBaseUrl(String rawBaseUrl) {
  final uri = Uri.parse(rawBaseUrl);

  if (uri.scheme == 'https') {
    return rawBaseUrl;
  }

  if (uri.scheme == 'http' && _isAllowedCleartextDevelopmentHost(uri.host)) {
    return rawBaseUrl;
  }

  throw StateError(
    'Insecure base URL is only allowed for local development hosts: $rawBaseUrl',
  );
}

bool _isAllowedCleartextDevelopmentHost(String host) {
  return host == 'localhost' ||
      host == '127.0.0.1' ||
      host == '10.0.2.2' ||
      host == '10.0.3.2' ||
      host.startsWith('192.168.') ||
      host.startsWith('10.') ||
      host.startsWith('172.16.') ||
      host.startsWith('172.17.') ||
      host.startsWith('172.18.') ||
      host.startsWith('172.19.') ||
      host.startsWith('172.20.') ||
      host.startsWith('172.21.') ||
      host.startsWith('172.22.') ||
      host.startsWith('172.23.') ||
      host.startsWith('172.24.') ||
      host.startsWith('172.25.') ||
      host.startsWith('172.26.') ||
      host.startsWith('172.27.') ||
      host.startsWith('172.28.') ||
      host.startsWith('172.29.') ||
      host.startsWith('172.30.') ||
      host.startsWith('172.31.');
}