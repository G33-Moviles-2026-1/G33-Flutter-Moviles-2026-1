import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/auth_providers.dart';
import '../di/core_provider.dart';
import '../navigation/app_routes.dart';
import 'analytics_events.dart';

class ScreenTimeRouteObserver extends NavigatorObserver {
  ScreenTimeRouteObserver(this.ref);

  final WidgetRef ref;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackRoute(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _trackRoute(previousRoute);
    }
  }

  void _trackRoute(Route<dynamic> route) {
    final screenName = _screenNameForRoute(route);
    if (screenName == null) return;

    unawaited(_trackScreenOpen(screenName));
  }

  Future<void> _trackScreenOpen(String screenName) async {
    try {
      final analytics = ref.read(analyticsServiceProvider);
      final session = ref.read(sessionControllerProvider.notifier);
      final savedUser = await ref
          .read(authLocalDataSourceProvider)
          .getSavedUser();

      await analytics.track(
        sessionId: session.sessionId,
        deviceId: session.deviceId,
        userEmail: savedUser?.email,
        eventName: AnalyticsEvents.openScreenTimestamp,
        screen: screenName,
        propsJson: {'source': 'navigator_observer'},
      );
    } catch (_) {
      // Screen-time analytics should never affect navigation.
    }
  }

  String? _screenNameForRoute(Route<dynamic> route) {
    final routeName = route.settings.name;
    if (routeName == null || routeName.isEmpty) return null;

    return switch (routeName) {
      AppRoutes.authGate => 'auth_gate',
      AppRoutes.home => 'home',
      AppRoutes.login => 'login',
      AppRoutes.signup => 'signup',
      AppRoutes.results => 'results',
      AppRoutes.roomDetail => 'room_detail',
      AppRoutes.createBooking => 'create_booking',
      AppRoutes.myBookings => 'my_bookings',
      AppRoutes.schedule => 'schedule',
      AppRoutes.path => 'path',
      AppRoutes.favorites => 'favorites',
      AppRoutes.noInternet => 'no_internet',
      _ => routeName.replaceAll('/', '').replaceAll('-', '_'),
    };
  }
}
