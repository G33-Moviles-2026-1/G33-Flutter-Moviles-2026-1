import 'package:andespace/features/bookings/domain/entities/booking_purpose.dart';
import 'package:andespace/features/bookings/presentation/notifiers/create_booking_state.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/rooms/domain/entities/time_range.dart';
import 'package:andespace/shared/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/create_booking_notifier.dart';

enum QuickBookingResult { created, queued }

Future<QuickBookingResult?> showQuickBookingDialog({
  required BuildContext context,
  required RoomSearchItem room,
}) {
  return showDialog<QuickBookingResult>(
    context: context,
    barrierDismissible: true,
    builder: (_) => QuickBookingDialog(room: room),
  );
}

class QuickBookingDialog extends ConsumerWidget {
  const QuickBookingDialog({super.key, required this.room});

  final RoomSearchItem room;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = createBookingControllerProvider(room);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;
    final isDark = theme.brightness == Brightness.dark;

    ref.listen<CreateBookingState>(provider, (previous, next) {
      final createdNow = previous?.created == null && next.created != null;
      if (createdNow) {
        Navigator.of(context).pop(QuickBookingResult.created);
        return;
      }

      final queuedNow = previous?.isPendingSync != true && next.isPendingSync;
      if (queuedNow) {
        Navigator.of(context).pop(QuickBookingResult.queued);
      }
    });

    final canConfirm =
        !state.isSubmitting &&
        !state.isLoadingAvailability &&
        state.selectedTimeRange != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF22242A) : const Color(0xFFFBF8FF),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.42 : 0.18),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Book: ${room.roomId}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),
            if (state.isLoadingAvailability) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  color: brand.accentYellow,
                  backgroundColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.08,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            _FieldLabel('Select Time Slot'),
            const SizedBox(height: 8),
            _QuickDropdown<TimeRange>(
              value: state.selectedTimeRange,
              hint: state.availableTimeRanges.isEmpty
                  ? 'No availability'
                  : 'Select time slot',
              items: state.availableTimeRanges,
              itemLabel: (range) => '${range.start} - ${range.end}',
              onChanged: state.availableTimeRanges.isEmpty
                  ? null
                  : controller.setTimeRange,
            ),
            const SizedBox(height: 18),
            _FieldLabel('Select Purpose'),
            const SizedBox(height: 8),
            _QuickDropdown<BookingPurpose>(
              value: state.selectedPurpose,
              hint: 'Meeting Purpose',
              items: BookingPurpose.values,
              itemLabel: (purpose) => purpose.label,
              onChanged: (purpose) {
                if (purpose != null) controller.setPurpose(purpose);
              },
            ),
            if (state.errorMessage != null ||
                state.availabilityErrorMessage != null) ...[
              const SizedBox(height: 14),
              Text(
                state.errorMessage ?? state.availabilityErrorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark
                          ? brand.accentYellow
                          : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: canConfirm ? controller.submit : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: brand.accentYellow,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : const Color(0xFFE0DCE5),
                      disabledForegroundColor: theme.colorScheme.onSurface
                          .withValues(alpha: 0.32),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _QuickDropdown<T> extends StatelessWidget {
  const _QuickDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final T? value;
  final String hint;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DropdownButtonFormField<T>(
      key: ValueKey<T?>(value),
      initialValue: value,
      isExpanded: true,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? const Color(0xFF191B20) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.secondary.withValues(alpha: 0.8),
          ),
        ),
      ),
      hint: Text(
        hint,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
