import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/shared/theme/app_theme_extension.dart';
import 'package:andespace/shared/widgets/auth_popup_menu.dart';
import 'package:andespace/shared/widgets/theme_popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.title = 'AndeSpace',
    this.onTapSearch,
    this.onTapLogo,
    this.onLogin,
    this.onSignUp,
    this.onLogout,
    this.searchIconPath = 'assets/icons/search.svg',
    this.userIconPath = 'assets/icons/user.svg',
    this.isLoggedIn = false,
  });

  final String title;
  final VoidCallback? onTapSearch;
  final VoidCallback? onTapLogo;
  final VoidCallback? onLogin;
  final VoidCallback? onSignUp;
  final VoidCallback? onLogout;

  final String searchIconPath;
  final String userIconPath;
  final bool isLoggedIn;

  Widget _buildSvgIcon(
    BuildContext context,
    String assetPath, {
    double size = 24,
  }) {
    final brand = Theme.of(context).extension<BrandColors>()!;

    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        brand.headerForeground,
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;

    return AppBar(
      backgroundColor: brand.headerBackground,
      foregroundColor: brand.headerForeground,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leadingWidth: 56,
      leading: ThemePopupMenu(
        icon: Icons.settings,
        iconColor: brand.headerForeground,
      ),
      title: GestureDetector(
        onTap: onTapLogo ?? () => Navigator.pushReplacementNamed(context, AppRoutes.home),
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
        IconButton(
          onPressed: onTapSearch,
          icon: _buildSvgIcon(context, searchIconPath),
        ),
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