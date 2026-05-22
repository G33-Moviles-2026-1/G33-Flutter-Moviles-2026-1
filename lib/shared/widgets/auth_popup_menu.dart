import 'package:andespace/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'anchored_popup_dialog.dart';

class AuthPopupMenu extends StatelessWidget {
  const AuthPopupMenu({
    super.key,
    required this.isLoggedIn,
    this.onLogin,
    this.onSignUp,
    this.onLogout,
    this.iconPath = 'assets/icons/user.svg',
    this.iconColor,
  });

  final bool isLoggedIn;
  final VoidCallback? onLogin;
  final VoidCallback? onSignUp;
  final VoidCallback? onLogout;
  final String iconPath;
  final Color? iconColor;

  void _showAuthDialog(BuildContext context) {
    showAnchoredPopupDialog(
      context: context,
      barrierLabel: 'Auth menu',
      right: 12,
      width: 320,
      padding: const EdgeInsets.all(20),
      builder: (dialogContext) {
        return isLoggedIn
            ? _LoggedInContent(
                onProfile: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pushNamed(AppRoutes.profile);
                },
                onSettings: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pushNamed(AppRoutes.settings);
                },
                onLogout: () {
                  Navigator.of(dialogContext).pop();
                  onLogout?.call();
                },
              )
            : _LoggedOutContent(
                onLogin: () {
                  Navigator.of(dialogContext).pop();
                  onLogin?.call();
                },
                onSignUp: () {
                  Navigator.of(dialogContext).pop();
                  onSignUp?.call();
                },
                onSettings: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pushNamed(AppRoutes.settings);
                },
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedIconColor =
        iconColor ??
        theme.appBarTheme.foregroundColor ??
        theme.colorScheme.onSurface;

    return IconButton(
      onPressed: () => _showAuthDialog(context),
      icon: SvgPicture.asset(
        iconPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          resolvedIconColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _LoggedOutContent extends StatelessWidget {
  const _LoggedOutContent({
    required this.onLogin,
    required this.onSignUp,
    required this.onSettings,
  });

  final VoidCallback onLogin;
  final VoidCallback onSignUp;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AuthButton(
          text: 'Log in',
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          onTap: onLogin,
        ),
        const SizedBox(height: 16),
        _AuthButton(
          text: 'Sign Up',
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          borderColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.black12,
          onTap: onSignUp,
        ),
        const SizedBox(height: 16),
        _AuthButton(
          text: 'Settings',
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          borderColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.black12,
          onTap: onSettings,
        ),
      ],
    );
  }
}

class _LoggedInContent extends StatelessWidget {
  const _LoggedInContent({
    required this.onProfile,
    required this.onSettings,
    required this.onLogout,
  });

  final VoidCallback onProfile;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white10 : Colors.black12;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AuthButton(
          text: 'Profile',
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          borderColor: borderColor,
          onTap: onProfile,
        ),
        const SizedBox(height: 16),
        _AuthButton(
          text: 'Settings',
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          borderColor: borderColor,
          onTap: onSettings,
        ),
        const SizedBox(height: 16),
        _AuthButton(
          text: 'Log out',
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          borderColor: borderColor,
          onTap: onLogout,
        ),
      ],
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
    this.borderColor,
  });

  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: backgroundColor,
      elevation: 4,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: borderColor != null ? Border.all(color: borderColor!) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: foregroundColor,
                ) ??
                TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: foregroundColor,
                ),
          ),
        ),
      ),
    );
  }
}