import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 3),
            color: theme.brightness == Brightness.dark
                ? const Color(0x14000000)
                : const Color(0x22000000),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '1 - $max',
          suffixText: 'people',
        ),
        onChanged: (raw) {
          final parsed = int.tryParse(raw);
          if (parsed == null) return;
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
