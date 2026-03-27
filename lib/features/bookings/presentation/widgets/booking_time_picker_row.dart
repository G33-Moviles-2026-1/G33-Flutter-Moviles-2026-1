import 'package:flutter/material.dart';
import '../../../rooms/domain/entities/time_range.dart';

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
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _formatRange(TimeRange r) {
    return '${r.start} - ${r.end}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BoxButton(
            label: _formatDate(selectedDate),
            onTap: onPickDate,
          ),
        ),
        const SizedBox(width: 10),
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
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            // FIX: spaceBetween keeps label left and icon right.
            // Flexible on the label lets it shrink/ellipsize before the icon
            // gets pushed off screen at large font sizes.
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.calendar_month,
                color: theme.colorScheme.onSurface,
              ),
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
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            // isExpanded: true already handles overflow inside the dropdown —
            // no changes needed here, it was already safe.
            isExpanded: true,
            value: value,
            hint: Text(
              hint,
              style: theme.textTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: theme.colorScheme.onSurface,
            ),
            items: items
                .map(
                  (e) => DropdownMenuItem<T>(
                    value: e,
                    child: Text(
                      itemLabel(e),
                      style: theme.textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
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