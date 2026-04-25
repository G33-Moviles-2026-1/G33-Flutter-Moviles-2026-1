import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/auth_user.dart';

abstract class AuthLocalDataSource {
  Future<void> saveSession(AuthUser user);
  Future<AuthUser?> getSavedUser();
  Future<bool> hasSavedSession();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _keyIsLoggedIn = 'auth_is_logged_in';
  static const _keyEmail = 'auth_user_email';

  @override
  Future<void> saveSession(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyEmail, user.email);
  }

  @override
  Future<AuthUser?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();

    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    final email = prefs.getString(_keyEmail);

    if (!isLoggedIn || email == null || email.trim().isEmpty) {
      return null;
    }

    return AuthUser(email: email);
  }

  @override
  Future<bool> hasSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  @override
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyEmail);
  }
}