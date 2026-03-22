import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_sensor/light_sensor.dart';

enum AppThemePreference {
  system,
  light,
  dark,
  automatic,
}

final themePreferenceProvider =
    StateNotifierProvider<ThemePreferenceNotifier, AppThemePreference>((ref) {
  final notifier = ThemePreferenceNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});

final effectiveThemeModeProvider = Provider<ThemeMode>((ref) {
  final preference = ref.watch(themePreferenceProvider);
  final notifier = ref.read(themePreferenceProvider.notifier);
  return notifier.resolveThemeMode(preference);
});

class ThemePreferenceNotifier extends StateNotifier<AppThemePreference> {
  ThemePreferenceNotifier() : super(AppThemePreference.system);

  static const int _darkThresholdLux = 20;
  static const int _lightThresholdLux = 35;

  StreamSubscription<int>? _luxSubscription;
  ThemeMode _automaticResolvedMode = ThemeMode.light;
  bool _sensorStarted = false;
  DateTime? _lastFlipAt;

  ThemeMode resolveThemeMode(AppThemePreference preference) {
    switch (preference) {
      case AppThemePreference.system:
        return ThemeMode.system;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
      case AppThemePreference.automatic:
        return _automaticResolvedMode;
    }
  }

  Future<void> setPreference(AppThemePreference preference) async {
    state = preference;

    if (preference == AppThemePreference.automatic) {
      await _startSensorIfNeeded();
    } else {
      await _stopSensor();
    }

    state = state;
  }

  Future<void> _startSensorIfNeeded() async {
    if (_sensorStarted) return;
    _sensorStarted = true;

    try {
      final hasSensor = await LightSensor.hasSensor();
      if (!hasSensor) {
        _automaticResolvedMode = ThemeMode.system;
        state = state;
        return;
      }

      _luxSubscription = LightSensor.luxStream().listen(
        _onLuxChanged,
        onError: (_) {
          _automaticResolvedMode = ThemeMode.system;
          state = state;
        },
      );
    } catch (_) {
      _automaticResolvedMode = ThemeMode.system;
      state = state;
    }
  }

  void _onLuxChanged(int lux) {
    if (state != AppThemePreference.automatic) return;

    final now = DateTime.now();

    if (_lastFlipAt != null &&
        now.difference(_lastFlipAt!) < const Duration(milliseconds: 900)) {
      return;
    }

    if (_automaticResolvedMode != ThemeMode.dark && lux <= _darkThresholdLux) {
      _automaticResolvedMode = ThemeMode.dark;
      _lastFlipAt = now;
      state = state;
      return;
    }

    if (_automaticResolvedMode != ThemeMode.light &&
        lux >= _lightThresholdLux) {
      _automaticResolvedMode = ThemeMode.light;
      _lastFlipAt = now;
      state = state;
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