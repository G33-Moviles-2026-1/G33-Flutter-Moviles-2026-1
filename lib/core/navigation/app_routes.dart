import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/features/auth/presentation/pages/auth_gate_page.dart';
import 'package:andespace/features/auth/presentation/pages/login_page.dart';
import 'package:andespace/features/auth/presentation/pages/signup_page.dart';
import 'package:andespace/features/bookings/presentation/pages/create_booking_page.dart';
import 'package:andespace/features/bookings/presentation/pages/my_bookings_page.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/rooms/presentation/pages/auto_search_page.dart';
import 'package:andespace/features/rooms/presentation/pages/home_page.dart';
import 'package:andespace/features/navigation/presentation/pages/path_page.dart';
import 'package:andespace/features/rooms/presentation/pages/results_page.dart';
import 'package:andespace/features/rooms/presentation/pages/room_detail_page.dart';
import 'package:andespace/features/schedule/presentation/pages/schedule_entry_page.dart';
import 'package:andespace/features/favorites/presentation/pages/favorites_page.dart';
import 'package:andespace/features/auth/presentation/pages/profile_page.dart';
import 'package:andespace/features/auth/presentation/pages/settings_page.dart';
import 'package:andespace/features/notifications/presentation/notifications_page.dart';
import 'package:andespace/features/friendships/presentation/pages/friends_page.dart';
import 'package:andespace/features/friendships/presentation/pages/add_friends_page.dart';
import 'package:andespace/features/rooms/presentation/pages/no_internet_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String authGate = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String results = '/results';
  static const String autoSearch = '/auto-search';
  static const String roomDetail = '/room-detail';
  static const String createBooking = '/create-booking';
  static const String myBookings = '/my-bookings';
  static const String schedule = '/schedule';
  static const String path = '/path';
  static const String favorites = '/favorites';
  static const String noInternet = '/no-internet';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String friends = '/friends';
  static const String addFriends = '/friends/add';

  static Map<String, WidgetBuilder> routes = {
    authGate: (context) => const AuthGatePage(),
    home: (context) => const HomePage(),
    login: (context) => const LoginPage(),
    signup: (context) => const SignUpPage(),
    results: (context) => const ResultsPage(),
    autoSearch: (context) => const AutoSearchPage(),
    schedule: (context) => const ScheduleEntryPage(),
    path: (context) {
      final room =
          ModalRoute.of(context)?.settings.arguments as RoomSearchItem?;
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
    noInternet: (context) => const NoInternetPage(),
    profile: (context) => const ProfilePage(),
    settings: (context) => const SettingsPage(),
    notifications: (context) => const NotificationsPage(),
    friends: (context) => const FriendsPage(),
    addFriends: (context) => const AddFriendsPage(),
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
