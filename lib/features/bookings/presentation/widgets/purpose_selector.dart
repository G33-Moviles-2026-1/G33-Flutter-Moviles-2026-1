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

    return Column(
      children: purposes
          .map(
            (p) => RadioListTile<BookingPurpose>(
              value: p,
              groupValue: selected,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
              title: Text(p.label),
            ),
          )
          .toList(),
    );
  }
}