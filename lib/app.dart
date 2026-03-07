import 'package:andespace/features/rooms/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'shared/theme/theme.dart';

class AndespaceApp extends StatelessWidget {
  const AndespaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: AppTheme.dark(),
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      home: const HomePage(),

    );
  }
}