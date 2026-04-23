import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/analytics/analytics_service.dart';
import 'core/di/core_provider.dart';
import 'core/local/app_database.dart';
import 'core/network/network_constants.dart';
import 'features/bookings/data/local/bookings_local_datasource.dart';
import 'features/bookings/presentation/providers/bookings_providers.dart';
import 'features/favorites/data/local/favorites_local_datasource.dart';
import 'features/favorites/presentation/providers/favorites_providers.dart';
import 'features/navigation/data/local/path_local_data_source.dart';
import 'features/navigation/presentation/providers/navigation_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final appDatabase = AppDatabase();
  final bookingsLocalDs = BookingsLocalDataSource(appDatabase);
  final favoritesLocalDs = FavoritesLocalDataSource(appDatabase);
  final pathLocalDs = PathLocalDataSource(appDatabase);

  final appDir = await getApplicationDocumentsDirectory();
  final cookiesPath = p.join(appDir.path, 'cookies');

  final cookieJar = PersistCookieJar(
    storage: FileStorage(cookiesPath),
    ignoreExpires: true,
  );

  final dio = Dio(
    BaseOptions(
      baseUrl: validatedBaseUrl(NetworkConstants.baseUrl),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(CookieManager(cookieJar));

  final analyticsService = AnalyticsService(dio);

  final container = ProviderContainer(
    overrides: [
      cookieJarProvider.overrideWithValue(cookieJar),
      dioProvider.overrideWithValue(dio),
      analyticsServiceProvider.overrideWithValue(analyticsService),
      bookingsLocalDataSourceProvider.overrideWithValue(bookingsLocalDs),
      favoritesLocalDataSourceProvider.overrideWithValue(favoritesLocalDs),
      pathLocalDataSourceProvider.overrideWithValue(pathLocalDs),
    ],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AndespaceApp(),
    ),
  );
}