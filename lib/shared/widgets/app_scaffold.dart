import 'package:andespace/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_footer.dart';
import 'app_header.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.body,
    required this.currentTab,
    required this.onTabSelected,
    this.onTapHeaderLeft,
    this.onLogin,
    this.onSignUp,
    //this.title = 'AndeSpace',
    this.extendBody = false,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;
  final VoidCallback? onTapHeaderLeft;
  final VoidCallback? onLogin;
  final VoidCallback? onSignUp;
  //final String title;
  final bool extendBody;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      appBar: AppHeader(
        //title: title,
        title: 'AndeSpace',
        onLogin: () {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        },

        onSignUp: () {
          Navigator.pushReplacementNamed(context, AppRoutes.signup);
        },
        onLogout: () async {
          await authController.logout();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        },
        isLoggedIn: authState.isAuthenticated,
        username: authState.user?.username,
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: AppFooter(
        currentTab: currentTab,
        onTabSelected: onTabSelected,
      ),
    );
  }
}
