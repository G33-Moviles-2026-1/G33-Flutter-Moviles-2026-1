import 'package:andespace/features/auth/presentation/pages/login_page.dart';
import 'package:andespace/features/auth/presentation/pages/signup_page.dart';
import 'package:andespace/features/rooms/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';


class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    login: (context) => const LoginPage(),
    signup: (context) => const SignUpPage(),
  };
}