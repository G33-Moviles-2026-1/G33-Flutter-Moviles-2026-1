import 'package:andespace/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'anchored_popup_dialog.dart';
import 'theme_popup_menu.dart';

class AuthPopupMenu extends ConsumerWidget {
  const AuthPopupMenu({
    super.key,
    required this.isLoggedIn,
    this.username,
    this.onLogin,
    this.onSignUp,
    this.onLogout,
    this.iconPath = 'assets/icons/user.svg',
    this.iconColor,
  });

  final bool isLoggedIn;
  final String? username;
  final VoidCallback? onLogin;
  final VoidCallback? onSignUp;
  final VoidCallback? onLogout;
  final String iconPath;
  final Color? iconColor;

  void _showTheme(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        showThemePopupDialog(context, ref, left: null, right: 12);
      }
    });
  }

  void _showAuthDialog(BuildContext context, WidgetRef ref) {
    showAnchoredPopupDialog(
      context: context,
      barrierLabel: 'Auth menu',
      right: 12,
      width: 320,
      padding: const EdgeInsets.all(16),
      builder: (dialogContext) {
        return isLoggedIn
            ? _LoggedInContent(
                username: username,
                onProfile: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pushNamed(AppRoutes.profile);
                },
                onFriends: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pushNamed(AppRoutes.friends);
                },
                onTheme: () {
                  Navigator.of(dialogContext).pop();
                  _showTheme(context, ref);
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
                onTheme: () {
                  Navigator.of(dialogContext).pop();
                  _showTheme(context, ref);
                },
              );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resolvedIconColor =
        iconColor ??
        theme.appBarTheme.foregroundColor ??
        theme.colorScheme.onSurface;

    return IconButton(
      tooltip: 'Account',
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      onPressed: () => _showAuthDialog(context, ref),
      icon: Center(
        child: SvgPicture.asset(
          iconPath,
          width: 22,
          height: 22,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(resolvedIconColor, BlendMode.srcIn),
        ),
      ),
    );
  }
}

class _LoggedOutContent extends StatelessWidget {
  const _LoggedOutContent({
    required this.onLogin,
    required this.onSignUp,
    required this.onTheme,
  });

  final VoidCallback onLogin;
  final VoidCallback onSignUp;
  final VoidCallback onTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MenuHeader(icon: Icons.person_outline, title: 'Welcome to AndeSpace'),
        const SizedBox(height: 16),
        _AuthButton(
          text: 'Log in',
          icon: Icons.login,
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          onTap: onLogin,
        ),
        const SizedBox(height: 10),
        _AuthButton(
          text: 'Sign Up',
          icon: Icons.person_add_alt_1,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          borderColor: theme.brightness == Brightness.dark
              ? Colors.white10
              : Colors.black12,
          onTap: onSignUp,
        ),
        const SizedBox(height: 12),
        _MenuActionTile(
          icon: Icons.palette_outlined,
          title: 'Theme',
          onTap: onTheme,
        ),
      ],
    );
  }
}

class _LoggedInContent extends StatelessWidget {
  const _LoggedInContent({
    required this.username,
    required this.onProfile,
    required this.onFriends,
    required this.onTheme,
    required this.onLogout,
  });

  final String? username;
  final VoidCallback onProfile;
  final VoidCallback onFriends;
  final VoidCallback onTheme;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedName = username?.trim().isNotEmpty == true
        ? username!.trim()
        : 'username';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MenuHeader(icon: Icons.person, title: 'Hello, $resolvedName'),
        const SizedBox(height: 16),
        _MenuActionTile(
          icon: Icons.account_circle_outlined,
          title: 'Profile',
          onTap: onProfile,
        ),
        const SizedBox(height: 16),
        _AuthButton(
          text: 'Friends',
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          borderColor: borderColor,
          onTap: onFriends,
        ),
        const SizedBox(height: 8),
        _MenuActionTile(
          icon: Icons.palette_outlined,
          title: 'Theme',
          onTap: onTheme,
        ),
        const SizedBox(height: 14),
        _AuthButton(
          text: 'Log out',
          icon: Icons.logout,
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          onTap: onLogout,
        ),
      ],
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.onSecondary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuActionTile extends StatelessWidget {
  const _MenuActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.secondary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withValues(alpha: 0.36),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
    this.borderColor,
  });

  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: backgroundColor,
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: borderColor != null
                ? Border.all(color: borderColor!)
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor, size: 20),
              const SizedBox(width: 8),
              Text(
                text,
                style:
                    textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: foregroundColor,
                    ) ??
                    TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: foregroundColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
