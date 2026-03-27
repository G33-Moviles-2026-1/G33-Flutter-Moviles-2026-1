import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme_extension.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/my_booking.dart';

class MyBookingCard extends StatelessWidget {
  const MyBookingCard({
    super.key,
    required this.booking,
    required this.isDeleting,
    required this.onDeleteTap,
  });

  final MyBooking booking;
  final bool isDeleting;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Already had Expanded — safe at any font size.
              Expanded(
                child: Text(
                  booking.roomId,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  // FIX: allow wrapping if roomId is long and font is large.
                  softWrap: true,
                ),
              ),
              if (isDeleting)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: onDeleteTap,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.black,
                  tooltip: 'Delete booking',
                ),
            ],
          ),
          const SizedBox(height: 6),
          // FIX: date and slot strings are standalone full-width Texts inside
          // a Column — they wrap naturally. Explicitly allow it with softWrap.
          Text(
            'Date: ${_formatDate(booking.date)}',
            style: theme.textTheme.bodyMedium,
            softWrap: true,
          ),
          const SizedBox(height: 4),
          Text(
            'Slot: ${booking.timeRange.start} - ${booking.timeRange.end}',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            softWrap: true,
          ),
          const SizedBox(height: 10),
          // Status pill: fixed short strings, always fits — no changes needed.
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: _statusColor(booking.status, brand),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Text(
                _statusLabel(booking.status),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(BookingStatus status, BrandColors? brand) {
    switch (status) {
      case BookingStatus.active:
        return brand?.accentYellow ?? Colors.yellow.shade300;
      case BookingStatus.completed:
        return Colors.grey.shade300;
      case BookingStatus.cancelled:
        return Colors.red.shade100;
    }
  }

  String _statusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.active:
        return 'Active';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}