import 'package:flutter/material.dart';
import '../../../rooms/domain/entities/time_range.dart';
import '../../../../shared/theme/theme.dart';

class BookingTimePickerRow extends StatelessWidget {
  const BookingTimePickerRow({
    super.key,
    required this.selectedDate,
    required this.availabilities,
    required this.selectedTimeRange,
    required this.onPickDate,
    required this.onSelectTimeRange,
  });

  final DateTime selectedDate;
  final List<TimeRange> availabilities;
  final TimeRange? selectedTimeRange;
  final VoidCallback onPickDate;
  final ValueChanged<TimeRange?> onSelectTimeRange;

  String _formatDate(DateTime d) {
    // Simple format, can upgrade later
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _formatRange(TimeRange r) {
    // Assumes TimeRange has string fields start/end like "06:30" — consistent with your mock.
    // If your TimeRange uses TimeOfDay, adjust here.
    return '${r.start} - ${r.end}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Date box
        Expanded(
          child: _BoxButton(
            label: _formatDate(selectedDate),
            onTap: onPickDate,
          ),
        ),
        const SizedBox(width: 10),
        // Time dropdown
        Expanded(
          child: _DropdownBox<TimeRange>(
            value: selectedTimeRange,
            items: availabilities,
            itemLabel: _formatRange,
            hint: availabilities.isEmpty ? 'No availability' : 'Select time',
            onChanged: availabilities.isEmpty ? null : onSelectTimeRange,
          ),
        ),
      ],
    );
  }
}

class _BoxButton extends StatelessWidget {
  const _BoxButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyLarge),
              const Spacer(),
              const Icon(Icons.calendar_month, color: AppColors.black),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownBox<T> extends StatelessWidget {
  const _DropdownBox({
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.hint,
    required this.onChanged,
  });

  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final String hint;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            value: value,
            hint: Text(hint, style: Theme.of(context).textTheme.bodyLarge),
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.black),
            items: items
                .map(
                  (e) => DropdownMenuItem<T>(
                    value: e,
                    child: Text(itemLabel(e), style: Theme.of(context).textTheme.bodyLarge),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}