import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'features/bookings/data/local/bookings_database.dart';
import 'features/bookings/data/local/bookings_local_datasource.dart';
import 'features/bookings/presentation/providers/bookings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final bookingsLocalDs = BookingsLocalDataSource(AppDatabase());

  runApp(
    ProviderScope(
      overrides: [
        bookingsLocalDataSourceProvider.overrideWithValue(bookingsLocalDs),
      ],
      child: const AndespaceApp(),
    ),
  );
}