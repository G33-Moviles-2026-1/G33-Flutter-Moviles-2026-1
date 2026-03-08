import 'package:flutter/material.dart';
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
    final purposes = BookingPurpose.values;

    return ListTileTheme(
      dense: true,
      horizontalTitleGap: 8,
      minVerticalPadding: 0,
      contentPadding: EdgeInsets.zero,
      child: Column(
        children: purposes.map((p) {
          return RadioListTile<BookingPurpose>(
            value: p,
            groupValue: selected,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
            dense: true,
            visualDensity: const VisualDensity(vertical: -3), // tighter!
            contentPadding: EdgeInsets.zero,
            title: Text(p.label),
          );
        }).toList(),
      ),
    );
  }
}