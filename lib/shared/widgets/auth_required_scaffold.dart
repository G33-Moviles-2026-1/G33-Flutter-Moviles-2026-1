import 'package:flutter/material.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/navigation/app_tab.dart';
import 'app_scaffold.dart';

class AuthRequiredScaffold extends StatelessWidget {
  const AuthRequiredScaffold({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    required this.title,
    required this.message,
    this.ctaLabel = 'Log In',
    this.icon = Icons.lock_outline_rounded,
    this.onLoginTap,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;
  final String title;
  final String message;
  final String ctaLabel;
  final IconData icon;
  final VoidCallback? onLoginTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AppScaffold(
      currentTab: currentTab,
      onTabSelected: onTabSelected,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 56,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: onLoginTap ??
                                  () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.login,
                                    );
                                  },
                              icon: const Icon(Icons.login),
                              label: Text(ctaLabel),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}