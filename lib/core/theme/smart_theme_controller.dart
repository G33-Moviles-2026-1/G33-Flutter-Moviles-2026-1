import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_sensor/light_sensor.dart';

final smartThemeModeProvider =
    StateNotifierProvider<SmartThemeController, ThemeMode>((ref) {
  final controller = SmartThemeController();
  controller.start();
  ref.onDispose(controller.dispose);
  return controller;
});

class SmartThemeController extends StateNotifier<ThemeMode> {
  SmartThemeController() : super(ThemeMode.light);

  static const int _darkThresholdLux = 20;
  static const int _lightThresholdLux = 35;

  StreamSubscription<int>? _luxSubscription;
  bool _started = false;
  DateTime? _lastFlipAt;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      final hasSensor = await LightSensor.hasSensor();
      if (!hasSensor) return;

      _luxSubscription = LightSensor.luxStream().listen(
        _onLuxChanged,
        onError: (_) {
          // Best effort: si falla el sensor, la app sigue con el tema actual.
        },
      );
    } catch (_) {
      // Si el sensor no está disponible o algo falla, no rompemos la app.
    }
  }

  void _onLuxChanged(int lux) {
    final now = DateTime.now();

    // Debounce simple para evitar parpadeos por cambios rapidísimos.
    if (_lastFlipAt != null &&
        now.difference(_lastFlipAt!) < const Duration(milliseconds: 900)) {
      return;
    }

    // Histéresis:
    // - si ya estamos en light, solo cambiamos a dark cuando baja bastante
    // - si ya estamos en dark, solo cambiamos a light cuando sube bastante
    if (state != ThemeMode.dark && lux <= _darkThresholdLux) {
      state = ThemeMode.dark;
      _lastFlipAt = now;
      return;
    }

    if (state != ThemeMode.light && lux >= _lightThresholdLux) {
      state = ThemeMode.light;
      _lastFlipAt = now;
    }
  }

  @override
  void dispose() {
    _luxSubscription?.cancel();
    super.dispose();
  }
}