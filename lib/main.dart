import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/local/app_database.dart';
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

  runApp(
    ProviderScope(
      overrides: [
        bookingsLocalDataSourceProvider.overrideWithValue(bookingsLocalDs),
        favoritesLocalDataSourceProvider.overrideWithValue(favoritesLocalDs),
        pathLocalDataSourceProvider.overrideWithValue(pathLocalDs),
      ],
      child: const AndespaceApp(),
    ),
  );
}