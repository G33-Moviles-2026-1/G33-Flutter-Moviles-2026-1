import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'features/bookings/data/local/bookings_local_datasource.dart';
import 'features/bookings/presentation/providers/bookings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Hive.initFlutter();
  final bookingsLocalDs = await BookingsLocalDataSource.open();

  runApp(
    ProviderScope(
      overrides: [
        bookingsLocalDataSourceProvider.overrideWithValue(bookingsLocalDs),
      ],
      child: const AndespaceApp(),
    ),
  );
}