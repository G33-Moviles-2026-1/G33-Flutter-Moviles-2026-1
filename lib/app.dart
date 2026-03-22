import 'package:andespace/core/di/theme_mode_provider.dart';
import 'package:andespace/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/theme/theme.dart';

class AndespaceApp extends ConsumerWidget {
  const AndespaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: AppTheme.dark(),
      theme: AppTheme.light(),
      themeMode: themeMode,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}