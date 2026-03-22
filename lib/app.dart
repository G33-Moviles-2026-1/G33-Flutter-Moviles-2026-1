import 'package:andespace/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/smart_theme_controller.dart';
import 'shared/theme/theme.dart';

class AndespaceApp extends ConsumerWidget {
  const AndespaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(smartThemeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: AppTheme.dark(),
      theme: AppTheme.light(),
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}