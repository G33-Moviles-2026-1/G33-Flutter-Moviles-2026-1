import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthPopupMenu extends StatelessWidget {
  const AuthPopupMenu({
    super.key,
    required this.isLoggedIn,
    this.onLogin,
    this.onSignUp,
    this.onLogout,
    this.iconPath = 'assets/icons/user.svg',
    this.iconColor = Colors.black,
  });

  final bool isLoggedIn;
  final VoidCallback? onLogin;
  final VoidCallback? onSignUp;
  final VoidCallback? onLogout;
  final String iconPath;
  final Color iconColor;

  void _showAuthDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: 'Auth menu',
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 70,
                right: 12,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 247, 247, 247),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 14,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: isLoggedIn
                        ? _LoggedInContent(
                            onLogout: () {
                              Navigator.of(context).pop();
                              onLogout?.call();
                            },
                          )
                        : _LoggedOutContent(
                            onLogin: () {
                              Navigator.of(context).pop();
                              onLogin?.call();
                            },
                            onSignUp: () {
                              Navigator.of(context).pop();
                              onSignUp?.call();
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );

        return FadeTransition(
          opacity: curved,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showAuthDialog(context),
      icon: SvgPicture.asset(
        iconPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          iconColor,
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
  });

  final VoidCallback onLogin;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AuthButton(
          text: 'Log in',
          color: const Color(0xFFFFF200),
          textColor: Colors.black,
          onTap: onLogin,
        ),
        const SizedBox(height: 16),
        _AuthButton(
          text: 'Sign Up',
          color: const Color.fromARGB(255, 255, 255, 255),
          textColor: Colors.black,
          onTap: onSignUp,
        ),
      ],
    );
  }
}

class _LoggedInContent extends StatelessWidget {
  const _LoggedInContent({
    required this.onLogout,
  });

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return _AuthButton(
      text: 'Log out',
      color: const Color(0xFFFFF200),
      textColor: Colors.black,
      borderColor: Colors.black12,
      onTap: onLogout,
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.text,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.borderColor,
  });

  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
