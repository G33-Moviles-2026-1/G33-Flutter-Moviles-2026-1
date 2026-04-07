import 'package:flutter/material.dart';
import 'app_theme_extension.dart';

abstract final class AppTheme {
  static const String fontBody = 'Poppins';
  static const String fontTitle = 'ADLaMDisplay';

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFFFFBA9),
      onPrimary: Color(0xFF000000),
      secondary: Color(0xFFFDF21C),
      onSecondary: Color(0xFF000000),
      error: Colors.red,
      onError: Colors.white,
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF000000),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
    );

    final textTheme = _buildTextTheme(base, colorScheme.onSurface);

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      textTheme: textTheme,

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFFFDF21C),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFBA9),
        foregroundColor: Color(0xFF000000),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFBA9),
        selectedItemColor: Color(0xFF000000),
        unselectedItemColor: Color(0xFF000000),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
        suffixIconColor: Colors.black54,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFCBD00),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          elevation: 3,
          shadowColor: Colors.black38,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          disabledForegroundColor: Colors.black54,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          side: const BorderSide(color: Colors.black),
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),

      extensions: const [
        BrandColors(
          softYellow: Color(0xFFFFFBA9),
          accentYellow: Color(0xFFFDF21C),
          headerBackground: Color(0xFFFFFBA9),
          footerBackground: Color(0xFFFFFBA9),
          headerForeground: Color(0xFF000000),
          footerSelected: Color(0xFF000000),
          footerUnselected: Color(0xFF000000),
        ),
      ],

      datePickerTheme: DatePickerThemeData(
        todayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.black;
          }
          return Color(0xFFFCBD00);
        }),

      ),

      timePickerTheme: const TimePickerThemeData(
        dialHandColor: Color(0xFFFDF21C),
        entryModeIconColor: Colors.white70,
      ),

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFFFCBD00),
        selectionColor: Color(0x33FCBD00),
        selectionHandleColor: Color(0xFFFCBD00),
      ),
    );
  }

  static ThemeData dark() {
    const background = Color(0xFF0F1115);
    const cardColor = Color(0xFF1A1D22);
    const onSurface = Color(0xFFF5F5F5);

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF121417),
      onPrimary: Color(0xFFF5F5F5),
      secondary: Color(0xFFFFA500),
      onSecondary: Color(0xFF000000),
      error: Colors.redAccent,
      onError: Colors.white,
      surface: background,
      onSurface: onSurface,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
    );

    final textTheme = _buildTextTheme(base, onSurface);

    return base.copyWith(
      scaffoldBackgroundColor: background,
      textTheme: textTheme,

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFFFFA500),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121417),
        foregroundColor: Color(0xFFF5F5F5),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF121417),
        selectedItemColor: Color(0xFFF5F5F5),
        unselectedItemColor: Color(0xFF9AA0A6),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(
          fontSize: 16,
          color: Colors.white60,
        ),
        suffixIconColor: Colors.white60,
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFFA500),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          elevation: 3,
          shadowColor: Colors.black54,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          side: const BorderSide(color: Colors.white24),
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),

      extensions: const [
        BrandColors(
          softYellow: Color(0xFFFFFBA9),
          accentYellow: Color(0xFFFFA500),
          headerBackground: Color(0xFF121417),
          footerBackground: Color(0xFF121417),
          headerForeground: Color(0xFFF5F5F5),
          footerSelected: Color(0xFFF5F5F5),
          footerUnselected: Color(0xFF9AA0A6),
        ),
      ],

      datePickerTheme: DatePickerThemeData(
        todayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Color(0xFFFFA500);
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFC78201);
          }
          return Colors.transparent;
        }),
        todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFC78201);
          }
          return Colors.transparent;
        }),

      ),
      

      timePickerTheme: const TimePickerThemeData(
        dialHandColor: Color(0xFFFFA500),
        entryModeIconColor: Colors.white70,
      ),

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFFFFA500),
        selectionColor: Color(0x33FFA500),
        selectionHandleColor: Color(0xFFFFA500),
      ),

    );
  }

  static TextTheme _buildTextTheme(ThemeData base, Color textColor) {
    return base.textTheme
        .apply(
          fontFamily: fontBody,
          bodyColor: textColor,
          displayColor: textColor,
        )
        .copyWith(
          displayLarge: base.textTheme.displayLarge?.copyWith(
            fontFamily: fontTitle,
          ),
          displayMedium: base.textTheme.displayMedium?.copyWith(
            fontFamily: fontTitle,
          ),
          displaySmall: base.textTheme.displaySmall?.copyWith(
            fontFamily: fontTitle,
          ),
          headlineLarge: base.textTheme.headlineLarge?.copyWith(
            fontFamily: fontTitle,
          ),
          headlineMedium: base.textTheme.headlineMedium?.copyWith(
            fontFamily: fontTitle,
          ),
          headlineSmall: base.textTheme.headlineSmall?.copyWith(
            fontFamily: fontTitle,
          ),
          titleLarge: base.textTheme.titleLarge?.copyWith(
            fontFamily: fontTitle,
          ),
        );
  }
}