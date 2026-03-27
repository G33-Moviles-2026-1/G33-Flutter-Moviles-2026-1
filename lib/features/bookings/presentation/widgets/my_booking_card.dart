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

    final isDark = theme.brightness == Brightness.dark;
    final cardColor =
        theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface;
    final borderColor = isDark
        ? theme.colorScheme.onSurface.withValues(alpha: 0.16)
        : Colors.black;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.22);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: isDark ? 1.0 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: isDark ? 12 : 0,
            spreadRadius: 0,
            offset: isDark ? const Offset(0, 4) : const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  booking.roomId,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                  softWrap: true,
                ),
              ),
              if (isDeleting)
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      brand?.accentYellow ?? theme.colorScheme.secondary,
                    ),
                  ),
                )
              else
                IconButton(
                  onPressed: onDeleteTap,
                  icon: const Icon(Icons.delete_outline),
                  color: theme.colorScheme.onSurface,
                  tooltip: 'Delete booking',
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Date: ${_formatDate(booking.date)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            softWrap: true,
          ),
          const SizedBox(height: 4),
          Text(
            'Slot: ${booking.timeRange.start} - ${booking.timeRange.end}',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            softWrap: true,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: _statusColor(context, booking.status, brand),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _statusBorderColor(context),
                  width: 1,
                ),
              ),
              child: Text(
                _statusLabel(booking.status),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _statusTextColor(context, booking.status),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(
    BuildContext context,
    BookingStatus status,
    BrandColors? brand,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (status) {
      case BookingStatus.active:
        return brand?.accentYellow ?? Colors.orange;
      case BookingStatus.completed:
        return isDark ? const Color(0xFF4B5563) : Colors.grey.shade300;
      case BookingStatus.cancelled:
        return isDark ? const Color(0xFF7F1D1D) : Colors.red.shade100;
    }
  }

  Color _statusTextColor(BuildContext context, BookingStatus status) {
    switch (status) {
      case BookingStatus.active:
        return Colors.black;
      case BookingStatus.completed:
      case BookingStatus.cancelled:
        return Colors.white;
    }
  }

  Color _statusBorderColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.transparent
        : Colors.black;
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