import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_routes.dart';
import 'shared/theme/theme.dart';
import 'core/di/theme_mode_provider.dart';

class AndespaceApp extends ConsumerWidget {
  const AndespaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeState.effectiveMode,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}