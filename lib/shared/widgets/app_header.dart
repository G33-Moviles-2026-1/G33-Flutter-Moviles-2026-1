import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/features/notifications/presentation/notifiers/notifications_notifier.dart';
import 'package:andespace/shared/theme/app_theme_extension.dart';
import 'package:andespace/shared/widgets/auth_popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.title = 'AndeSpace',
    this.onTapLogo,
    this.onLogin,
    this.onSignUp,
    this.onLogout,
    this.userIconPath = 'assets/icons/user.svg',
    this.isLoggedIn = false,
  });

  final String title;
  final VoidCallback? onTapLogo;
  final VoidCallback? onLogin;
  final VoidCallback? onSignUp;
  final VoidCallback? onLogout;
  final String userIconPath;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;
    final unread = ref.watch(
      notificationsControllerProvider.select((s) => s.unread),
    );

    return AppBar(
      backgroundColor: brand.headerBackground,
      foregroundColor: brand.headerForeground,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leadingWidth: 56,
      leading: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 99 ? '99+' : '$unread'),
        child: IconButton(
          icon: Icon(Icons.notifications_none, color: brand.headerForeground),
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.notifications),
        ),
      ),
      title: GestureDetector(
        onTap: onTapLogo ??
            () => Navigator.pushReplacementNamed(context, AppRoutes.home),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: brand.headerForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: AuthPopupMenu(
            isLoggedIn: isLoggedIn,
            onLogin: onLogin,
            onSignUp: onSignUp,
            onLogout: onLogout,
            iconPath: userIconPath,
            iconColor: brand.headerForeground,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
