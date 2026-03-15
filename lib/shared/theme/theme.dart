import 'package:flutter/material.dart';
import 'app_theme_extension.dart';

abstract final class AppTheme {
  static const String fontBody = 'Poppins';
  static const String fontTitle = 'ADLaMDisplay';

  static ThemeData light() {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);

    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFFFFBA9),
      onPrimary: Color(0xFF000000),
      secondary: Color(0xFFFDF21C),
      onSecondary: Color(0xFF000000),
      error: Colors.red,
      onError: Colors.white,
      surface: Color.fromARGB(255, 255, 255, 255),
      onSurface: Color(0xFF000000),
    );

    final textTheme = base.textTheme
        .apply(
          fontFamily: fontBody,
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
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

    final lightButtonTextStyle = TextButton.styleFrom(
      foregroundColor: colorScheme.onSurface,
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color.fromARGB(255, 245, 245, 245),
      textTheme: textTheme,

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

      // NEW: makes default dialog/picker text buttons readable
      textButtonTheme: TextButtonThemeData(style: lightButtonTextStyle),

      // NEW: date picker button/text readability
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: colorScheme.surface,
        headerForegroundColor: colorScheme.onSurface,
        weekdayStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        dayStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        yearStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        todayForegroundColor: WidgetStatePropertyAll(colorScheme.onSurface),
        todayBackgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onSecondary;
          }
          return colorScheme.onSurface;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.secondary;
          }
          return null;
        }),
        confirmButtonStyle: lightButtonTextStyle,
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.black54,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // NEW: time picker button/text readability
      timePickerTheme: TimePickerThemeData(
        backgroundColor: colorScheme.surface,
        helpTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        hourMinuteTextStyle: textTheme.headlineMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        hourMinuteTextColor: colorScheme.onSurface,
        dayPeriodTextColor: colorScheme.onSurface,
        dayPeriodBorderSide: BorderSide(color: Colors.black26),
        dialHandColor: colorScheme.secondary,
        dialBackgroundColor: const Color(0xFFF2F2F2),
        dialTextColor: colorScheme.onSurface,
        entryModeIconColor: colorScheme.onSurface,
        confirmButtonStyle: lightButtonTextStyle,
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.black54,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
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
    );
  }

  static ThemeData dark() {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);

    const background = Color(0xFF0F1115);
    const surface = Color(0xFF121417);
    const onSurface = Color(0xFFF5F5F5);

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: surface,
      onPrimary: onSurface,
      secondary: Color(0xFFFDF21C),
      onSecondary: Color(0xFF000000),
      error: Colors.redAccent,
      onError: Colors.white,
      surface: background,
      onSurface: onSurface,
    );

    final textTheme = base.textTheme
        .apply(
          fontFamily: fontBody,
          bodyColor: onSurface,
          displayColor: onSurface,
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

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
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
      extensions: const [
        BrandColors(
          softYellow: Color(0xFFFFFBA9),
          accentYellow: Color(0xFFFDF21C),
          headerBackground: Color(0xFF121417),
          footerBackground: Color(0xFF121417),
          headerForeground: Color(0xFFF5F5F5),
          footerSelected: Color(0xFFF5F5F5),
          footerUnselected: Color(0xFF9AA0A6),
        ),
      ],
    );
  }
}
