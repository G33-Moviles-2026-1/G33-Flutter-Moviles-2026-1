import 'package:flutter/material.dart';

class ScheduleImportOptionCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final IconData icon;

  static const _cardBorderRadius = BorderRadius.all(Radius.circular(18));
  static const _iconBorderRadius = BorderRadius.all(Radius.circular(14));
  static const _contentPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 18,
  );

  const ScheduleImportOptionCard({
    super.key,
    required this.title,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: _cardBorderRadius,
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.16)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: _cardBorderRadius,
          child: Padding(
            padding: _contentPadding,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.16),
                    borderRadius: _iconBorderRadius,
                  ),
                  child: Icon(icon, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
