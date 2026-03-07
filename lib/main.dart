import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/shared/theme/theme.dart';
import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'app.dart';

void main() {
  runApp(const AndespaceApp());
=======
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AndeSpace',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
>>>>>>> Stashed changes
}