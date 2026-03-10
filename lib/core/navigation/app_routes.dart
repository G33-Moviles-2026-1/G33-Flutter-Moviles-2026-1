import 'package:andespace/features/auth/presentation/pages/login_page.dart';
import 'package:andespace/features/auth/presentation/pages/signup_page.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/rooms/presentation/pages/home_page.dart';
import 'package:andespace/features/rooms/presentation/pages/results_page.dart';
import 'package:andespace/features/rooms/presentation/pages/room_detail_page.dart';
import 'package:flutter/material.dart';


class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String results = '/results';
  static const String roomDetail = '/room-detail';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    login: (context) => const LoginPage(),
    signup: (context) => const SignUpPage(),
    results: (context) => const ResultsPage(),
    roomDetail: (context) {
      final room = ModalRoute.of(context)!.settings.arguments as RoomSearchItem;
      return RoomDetailPage(room: room);
    },
  };
}