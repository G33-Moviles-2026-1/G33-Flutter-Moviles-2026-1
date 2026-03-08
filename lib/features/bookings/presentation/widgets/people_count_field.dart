import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';

class PeopleCountField extends StatelessWidget {
  const PeopleCountField({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value.toString());

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 3),
            color: Color(0x22000000),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '1 - $max',
          suffixText: 'people',
        ),
        onChanged: (raw) {
          final parsed = int.tryParse(raw);
          if (parsed == null) return; // ignore non-numeric
          final clamped = parsed.clamp(1, max);
          if (clamped != value) onChanged(clamped);
        },
        onSubmitted: (raw) {
          final parsed = int.tryParse(raw);
          final clamped = (parsed ?? 1).clamp(1, max);
          if (clamped != value) onChanged(clamped);
        },
      ),
    );
  }
}