import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand palette
  static const Color softYellow = Color(0xFFFFFBA9);
  static const Color accentYellow = Color(0xFFFDF21C);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic roles
  static const Color backgroundLight = white;
  static const Color backgroundDark = black;

  static const Color foregroundLight = black;
  static const Color foregroundDark = white;
}

abstract final class AppTheme {
  static const String fontBody = 'Poppins';
  static const String fontTitle = 'ADLaMDisplay';

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );

    final textTheme = base.textTheme.apply(
      fontFamily: fontBody,
      bodyColor: AppColors.foregroundLight,
      displayColor: AppColors.foregroundLight,
    ).copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(fontFamily: fontTitle),
      displayMedium: base.textTheme.displayMedium?.copyWith(fontFamily: fontTitle),
      displaySmall: base.textTheme.displaySmall?.copyWith(fontFamily: fontTitle),
      headlineLarge: base.textTheme.headlineLarge?.copyWith(fontFamily: fontTitle),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(fontFamily: fontTitle),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(fontFamily: fontTitle),
      titleLarge: base.textTheme.titleLarge?.copyWith(fontFamily: fontTitle),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.softYellow,
        onPrimary: AppColors.black,
        secondary: AppColors.accentYellow,
        onSecondary: AppColors.black,
        error: Colors.red,
        onError: Colors.white,
        background: AppColors.backgroundLight,
        onBackground: AppColors.black,
        surface: AppColors.backgroundLight,
        onSurface: AppColors.black,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.softYellow,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.softYellow,
        selectedItemColor: AppColors.black,
        unselectedItemColor: AppColors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );

    final textTheme = base.textTheme.apply(
      fontFamily: fontBody,
      bodyColor: AppColors.foregroundDark,
      displayColor: AppColors.foregroundDark,
    ).copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(fontFamily: fontTitle),
      displayMedium: base.textTheme.displayMedium?.copyWith(fontFamily: fontTitle),
      displaySmall: base.textTheme.displaySmall?.copyWith(fontFamily: fontTitle),
      headlineLarge: base.textTheme.headlineLarge?.copyWith(fontFamily: fontTitle),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(fontFamily: fontTitle),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(fontFamily: fontTitle),
      titleLarge: base.textTheme.titleLarge?.copyWith(fontFamily: fontTitle),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.softYellow,
        onPrimary: AppColors.black,
        secondary: AppColors.accentYellow,
        onSecondary: AppColors.black,
        error: Colors.red,
        onError: Colors.white,
        background: AppColors.backgroundDark,
        onBackground: AppColors.white,
        surface: AppColors.backgroundDark,
        onSurface: AppColors.white,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.softYellow,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.softYellow,
        selectedItemColor: AppColors.black,
        unselectedItemColor: AppColors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}