import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/features/auth/presentation/pages/login_page.dart';
import 'package:andespace/features/auth/presentation/pages/signup_page.dart';
import 'package:andespace/features/bookings/presentation/pages/create_booking_page.dart';
import 'package:andespace/features/bookings/presentation/pages/my_bookings_page.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/rooms/presentation/pages/home_page.dart';
import 'package:andespace/features/navigation/presentation/pages/path_page.dart';
import 'package:andespace/features/rooms/presentation/pages/results_page.dart';
import 'package:andespace/features/rooms/presentation/pages/room_detail_page.dart';
import 'package:andespace/features/schedule/presentation/pages/schedule_entry_page.dart';
import 'package:andespace/features/favorites/presentation/pages/favorites_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String results = '/results';
  static const String roomDetail = '/room-detail';
  static const String createBooking = '/create-booking';
  static const String myBookings = '/my-bookings';
  static const String schedule = '/schedule';
  static const String path = '/path';
  static const String favorites = '/favorites';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    login: (context) => const LoginPage(),
    signup: (context) => const SignUpPage(),
    results: (context) => const ResultsPage(),
    schedule: (context) => const ScheduleEntryPage(),
    path: (context) {
      final room = ModalRoute.of(context)?.settings.arguments as RoomSearchItem?;
      return PathPage(initialDestination: room);
    },
    roomDetail: (context) {
      final room = ModalRoute.of(context)!.settings.arguments as RoomSearchItem;
      return RoomDetailPage(room: room);
    },
    createBooking: (context) {
      final room = ModalRoute.of(context)!.settings.arguments as RoomSearchItem;
      return CreateBookingPage(room: room);
    },
    myBookings: (context) => const MyBookingsPage(),
    favorites: (context) => const FavoritesPage(),
  };

  static void handleTabSelection(BuildContext context, AppTab tab) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    switch (tab) {
      case AppTab.rooms:
        if (currentRoute != home) {
          Navigator.pushReplacementNamed(context, home);
        }
        break;
      case AppTab.bookings:
        if (currentRoute != myBookings) {
          Navigator.pushReplacementNamed(context, myBookings);
        }
        break;
      case AppTab.path:
        if (currentRoute != path) {
          Navigator.pushReplacementNamed(context, path);
        }
        break;
      case AppTab.schedule:
        if (currentRoute != schedule) {
          Navigator.pushReplacementNamed(context, schedule);
        }
        break;
      case AppTab.favorites:
        if (currentRoute != favorites) {
          Navigator.pushReplacementNamed(context, favorites);
        }
        break;
    }
  }
}
