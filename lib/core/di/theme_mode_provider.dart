import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_sensor/light_sensor.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreference {
  system,
  light,
  dark,
  automatic,
}

class ThemeControllerState {
  final AppThemePreference preference;
  final ThemeMode effectiveMode;

  const ThemeControllerState({
    required this.preference,
    required this.effectiveMode,
  });

  ThemeControllerState copyWith({
    AppThemePreference? preference,
    ThemeMode? effectiveMode,
  }) {
    return ThemeControllerState(
      preference: preference ?? this.preference,
      effectiveMode: effectiveMode ?? this.effectiveMode,
    );
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeControllerNotifier, ThemeControllerState>((ref) {
      final notifier = ThemeControllerNotifier();
      ref.onDispose(notifier.dispose);
      return notifier;
    });

class ThemeControllerNotifier extends StateNotifier<ThemeControllerState> {
  ThemeControllerNotifier()
      : super(
          const ThemeControllerState(
            preference: AppThemePreference.system,
            effectiveMode: ThemeMode.system,
          ),
        ) {
    _loadSavedPreference();
  }

  static const int _darkThresholdLux = 20;
  static const int _lightThresholdLux = 35;
  static const String _prefsKey = 'theme_preference';

  StreamSubscription<int>? _luxSubscription;
  bool _sensorStarted = false;
  DateTime? _lastFlipAt;

  Future<void> setPreference(AppThemePreference preference) async {
    await _savePreference(preference);

    if (preference == AppThemePreference.system) {
      await _stopSensor();
      state = state.copyWith(
        preference: preference,
        effectiveMode: ThemeMode.system,
      );
      return;
    }

    if (preference == AppThemePreference.light) {
      await _stopSensor();
      state = state.copyWith(
        preference: preference,
        effectiveMode: ThemeMode.light,
      );
      return;
    }

    if (preference == AppThemePreference.dark) {
      await _stopSensor();
      state = state.copyWith(
        preference: preference,
        effectiveMode: ThemeMode.dark,
      );
      return;
    }

    state = state.copyWith(
      preference: AppThemePreference.automatic,
    );

    await _startSensorIfNeeded();
  }

  Future<void> _loadSavedPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawValue = prefs.getString(_prefsKey);
      final savedPreference = _decodePreference(rawValue);

      await _applyLoadedPreference(savedPreference);
    } catch (_) {
      // If reading preferences fails, keep current default system mode.
    }
  }

  Future<void> _applyLoadedPreference(AppThemePreference preference) async {
    if (preference == AppThemePreference.system) {
      await _stopSensor();
      state = state.copyWith(
        preference: AppThemePreference.system,
        effectiveMode: ThemeMode.system,
      );
      return;
    }

    if (preference == AppThemePreference.light) {
      await _stopSensor();
      state = state.copyWith(
        preference: AppThemePreference.light,
        effectiveMode: ThemeMode.light,
      );
      return;
    }

    if (preference == AppThemePreference.dark) {
      await _stopSensor();
      state = state.copyWith(
        preference: AppThemePreference.dark,
        effectiveMode: ThemeMode.dark,
      );
      return;
    }

    state = state.copyWith(
      preference: AppThemePreference.automatic,
    );

    await _startSensorIfNeeded();
  }

  Future<void> _savePreference(AppThemePreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, preference.name);
  }

  AppThemePreference _decodePreference(String? rawValue) {
    return AppThemePreference.values.where((value) => value.name == rawValue).firstOrNull ??
        AppThemePreference.system;
  }

  Future<void> _startSensorIfNeeded() async {
    if (_sensorStarted) return;
    _sensorStarted = true;

    try {
      final hasSensor = await LightSensor.hasSensor();
      if (!hasSensor) {
        state = state.copyWith(effectiveMode: ThemeMode.system);
        return;
      }

      _luxSubscription = LightSensor.luxStream().listen(
        _onLuxChanged,
        onError: (_) {
          state = state.copyWith(effectiveMode: ThemeMode.system);
        },
      );
    } catch (_) {
      state = state.copyWith(effectiveMode: ThemeMode.system);
    }
  }

  void _onLuxChanged(int lux) {
    if (state.preference != AppThemePreference.automatic) return;

    final now = DateTime.now();

    if (_lastFlipAt != null &&
        now.difference(_lastFlipAt!) < const Duration(milliseconds: 900)) {
      return;
    }

    if (state.effectiveMode != ThemeMode.dark && lux <= _darkThresholdLux) {
      _lastFlipAt = now;
      state = state.copyWith(effectiveMode: ThemeMode.dark);
      return;
    }

    if (state.effectiveMode != ThemeMode.light && lux >= _lightThresholdLux) {
      _lastFlipAt = now;
      state = state.copyWith(effectiveMode: ThemeMode.light);
    }
  }

  Future<void> _stopSensor() async {
    await _luxSubscription?.cancel();
    _luxSubscription = null;
    _sensorStarted = false;
  }

  @override
  void dispose() {
    _luxSubscription?.cancel();
    super.dispose();
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}