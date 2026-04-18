import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme_extension.dart';
import '../../domain/entities/booking_purpose.dart';

class PurposeSelector extends StatelessWidget {
  const PurposeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final BookingPurpose selected;
  final ValueChanged<BookingPurpose> onChanged;

  @override
  Widget build(BuildContext context) {
    const purposes = BookingPurpose.values;
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>();

    final radioColor = brand?.accentYellow ?? theme.colorScheme.secondary;

    return RadioGroup<BookingPurpose>(
      groupValue: selected,
      onChanged: (BookingPurpose? value) {
        if (value != null) {
          onChanged(value);
        }
      },
      child: ListTileTheme(
        dense: true,
        horizontalTitleGap: 8,
        minVerticalPadding: 0,
        contentPadding: EdgeInsets.zero,
        child: Column(
          children: purposes.map((p) {
            return RadioListTile<BookingPurpose>(
              value: p,
              activeColor: radioColor,
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return radioColor;
                }
                return theme.colorScheme.onSurface;
              }),
              dense: true,
              visualDensity: const VisualDensity(vertical: -3),
              contentPadding: EdgeInsets.zero,
              title: Text(
                p.label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}