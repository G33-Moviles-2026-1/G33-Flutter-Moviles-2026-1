import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/theme_mode_provider.dart';

class ThemePopupMenu extends ConsumerWidget {
  const ThemePopupMenu({
    super.key,
    this.icon = Icons.settings,
    this.iconColor,
  });

  final IconData icon;
  final Color? iconColor;

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentPreference = ref.read(themeControllerProvider).preference;

    showGeneralDialog(
      context: context,
      barrierLabel: 'Theme menu',
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 70,
                left: 12,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _ThemeOptionTile(
                          label: 'Automatic',
                          subtitle: 'Uses ambient light sensor',
                          selected:
                              currentPreference == AppThemePreference.automatic,
                          onTap: () async {
                            await ref
                                .read(themeControllerProvider.notifier)
                                .setPreference(AppThemePreference.automatic);
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        _ThemeOptionTile(
                          label: 'System',
                          subtitle: 'Follows device theme',
                          selected:
                              currentPreference == AppThemePreference.system,
                          onTap: () async {
                            await ref
                                .read(themeControllerProvider.notifier)
                                .setPreference(AppThemePreference.system);
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        _ThemeOptionTile(
                          label: 'Light',
                          selected:
                              currentPreference == AppThemePreference.light,
                          onTap: () async {
                            await ref
                                .read(themeControllerProvider.notifier)
                                .setPreference(AppThemePreference.light);
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        _ThemeOptionTile(
                          label: 'Dark',
                          selected: currentPreference == AppThemePreference.dark,
                          onTap: () async {
                            await ref
                                .read(themeControllerProvider.notifier)
                                .setPreference(AppThemePreference.dark);
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                        ),
                      ],
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resolvedIconColor =
        iconColor ??
        theme.appBarTheme.foregroundColor ??
        theme.colorScheme.onSurface;

    return IconButton(
      onPressed: () => _showThemeDialog(context, ref),
      icon: Icon(
        icon,
        color: resolvedIconColor,
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected
          ? theme.colorScheme.secondary.withValues(alpha: 0.16)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.secondary
                  : theme.dividerColor.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}