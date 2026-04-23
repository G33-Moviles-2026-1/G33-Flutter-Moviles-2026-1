import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:andespace/core/navigation/app_routes.dart';
import '../controllers/auth_notifier.dart';

class AuthGatePage extends ConsumerStatefulWidget {
  const AuthGatePage({super.key});

  @override
  ConsumerState<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends ConsumerState<AuthGatePage> {
  bool _didCheckAuth = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(authControllerProvider.notifier).loadCurrentUser();

      if (!mounted) return;

      final authState = ref.read(authControllerProvider);

      final targetRoute = authState.isAuthenticated
          ? AppRoutes.home
          : AppRoutes.login;

      Navigator.pushReplacementNamed(context, targetRoute);

      _didCheckAuth = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_didCheckAuth) {
      return const SizedBox.shrink();
    }

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}