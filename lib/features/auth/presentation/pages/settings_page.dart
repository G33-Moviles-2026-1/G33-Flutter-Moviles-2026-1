import 'package:andespace/core/di/theme_mode_provider.dart';
import 'package:andespace/shared/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;
    final preference = ref.watch(themeModeProvider).preference;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: brand.headerBackground,
        foregroundColor: brand.headerForeground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
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
            selected: preference == AppThemePreference.automatic,
            onTap: () => ref
                .read(themeModeProvider.notifier)
                .setPreference(AppThemePreference.automatic),
          ),
          const SizedBox(height: 10),
          _ThemeOptionTile(
            label: 'System',
            subtitle: 'Follows device theme',
            selected: preference == AppThemePreference.system,
            onTap: () => ref
                .read(themeModeProvider.notifier)
                .setPreference(AppThemePreference.system),
          ),
          const SizedBox(height: 10),
          _ThemeOptionTile(
            label: 'Light',
            selected: preference == AppThemePreference.light,
            onTap: () => ref
                .read(themeModeProvider.notifier)
                .setPreference(AppThemePreference.light),
          ),
          const SizedBox(height: 10),
          _ThemeOptionTile(
            label: 'Dark',
            selected: preference == AppThemePreference.dark,
            onTap: () => ref
                .read(themeModeProvider.notifier)
                .setPreference(AppThemePreference.dark),
          ),
        ],
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                      Text(subtitle!, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              if (selected) Icon(Icons.check, size: 18, color: theme.colorScheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
