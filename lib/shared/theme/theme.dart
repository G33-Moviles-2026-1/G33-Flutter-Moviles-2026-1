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
      progressIndicatorTheme: _buildProgressIndicatorTheme(
        color: const Color(0xFFFDF21C),
      ),
      appBarTheme: _buildAppBarTheme(
        backgroundColor: const Color(0xFFFFFBA9),
        foregroundColor: const Color(0xFF000000),
      ),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(
        backgroundColor: const Color(0xFFFFFBA9),
        selectedItemColor: const Color(0xFF000000),
        unselectedItemColor: const Color(0xFF000000),
      ),
      inputDecorationTheme: _buildInputDecorationTheme(
        hintColor: Colors.black54,
        fillColor: Colors.white,
        focusedBorderColor: Colors.black12,
        errorBorderColor: Colors.redAccent,
      ),
      textButtonTheme: _buildTextButtonTheme(
        foregroundColor: const Color(0xFFFCBD00),
      ),
      elevatedButtonTheme: _buildElevatedButtonTheme(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        shadowColor: Colors.black38,
        disabledForegroundColor: Colors.black54,
      ),
      outlinedButtonTheme: _buildOutlinedButtonTheme(
        foregroundColor: Colors.black,
        sideColor: Colors.black,
      ),
      snackBarTheme: _snackBarTheme,
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
      datePickerTheme: _buildDatePickerTheme(
        todayUnselectedForeground: const Color(0xFFFCBD00),
        todaySelectedForeground: Colors.black,
      ),
      timePickerTheme: _buildTimePickerTheme(
        dialHandColor: const Color(0xFFFDF21C),
      ),
      textSelectionTheme: _buildTextSelectionTheme(
        accentColor: const Color(0xFFFCBD00),
        selectionColor: const Color(0x33FCBD00),
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
      progressIndicatorTheme: _buildProgressIndicatorTheme(
        color: const Color(0xFFFFA500),
      ),
      appBarTheme: _buildAppBarTheme(
        backgroundColor: const Color(0xFF121417),
        foregroundColor: const Color(0xFFF5F5F5),
      ),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(
        backgroundColor: const Color(0xFF121417),
        selectedItemColor: const Color(0xFFF5F5F5),
        unselectedItemColor: const Color(0xFF9AA0A6),
      ),
      inputDecorationTheme: _buildInputDecorationTheme(
        hintColor: Colors.white60,
        fillColor: cardColor,
        focusedBorderColor: Colors.white24,
        errorBorderColor: Colors.redAccent,
      ),
      textButtonTheme: _buildTextButtonTheme(
        foregroundColor: const Color(0xFFFFA500),
      ),
      elevatedButtonTheme: _buildElevatedButtonTheme(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        shadowColor: Colors.black54,
      ),
      outlinedButtonTheme: _buildOutlinedButtonTheme(
        foregroundColor: onSurface,
        sideColor: Colors.white24,
      ),
      snackBarTheme: _snackBarTheme,
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
      datePickerTheme: _buildDatePickerTheme(
        todayUnselectedForeground: const Color(0xFFFFA500),
        todaySelectedForeground: Colors.white,
        selectedDayBackground: const Color(0xFFC78201),
        selectedTodayBackground: const Color(0xFFC78201),
      ),
      timePickerTheme: _buildTimePickerTheme(
        dialHandColor: const Color(0xFFFFA500),
      ),
      textSelectionTheme: _buildTextSelectionTheme(
        accentColor: const Color(0xFFFFA500),
        selectionColor: const Color(0x33FFA500),
      ),
    );
  }

  static const SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
  );

  static ProgressIndicatorThemeData _buildProgressIndicatorTheme({
    required Color color,
  }) {
    return ProgressIndicatorThemeData(color: color);
  }

  static AppBarTheme _buildAppBarTheme({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme({
    required Color backgroundColor,
    required Color selectedItemColor,
    required Color unselectedItemColor,
  }) {
    return BottomNavigationBarThemeData(
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme({
    required Color hintColor,
    required Color fillColor,
    required Color focusedBorderColor,
    required Color errorBorderColor,
  }) {
    return InputDecorationTheme(
      hintStyle: TextStyle(
        fontSize: 16,
        color: hintColor,
      ),
      suffixIconColor: hintColor,
      filled: true,
      fillColor: fillColor,
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
        borderSide: BorderSide(color: focusedBorderColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: errorBorderColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: errorBorderColor),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme({
    required Color foregroundColor,
  }) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme({
    required Color backgroundColor,
    required Color foregroundColor,
    required Color shadowColor,
    Color? disabledForegroundColor,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 3,
        shadowColor: shadowColor,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        disabledForegroundColor: disabledForegroundColor,
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme({
    required Color foregroundColor,
    required Color sideColor,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        side: BorderSide(color: sideColor),
      ),
    );
  }

  static DatePickerThemeData _buildDatePickerTheme({
    required Color todayUnselectedForeground,
    required Color todaySelectedForeground,
    Color? selectedDayBackground,
    Color? selectedTodayBackground,
  }) {
    return DatePickerThemeData(
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return todaySelectedForeground;
        }
        return todayUnselectedForeground;
      }),
      dayBackgroundColor: selectedDayBackground == null
          ? null
          : WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return selectedDayBackground;
              }
              return Colors.transparent;
            }),
      todayBackgroundColor: selectedTodayBackground == null
          ? null
          : WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return selectedTodayBackground;
              }
              return Colors.transparent;
            }),
    );
  }

  static TimePickerThemeData _buildTimePickerTheme({
    required Color dialHandColor,
  }) {
    return TimePickerThemeData(
      dialHandColor: dialHandColor,
      entryModeIconColor: Colors.white70,
    );
  }

  static TextSelectionThemeData _buildTextSelectionTheme({
    required Color accentColor,
    required Color selectionColor,
  }) {
    return TextSelectionThemeData(
      cursorColor: accentColor,
      selectionColor: selectionColor,
      selectionHandleColor: accentColor,
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