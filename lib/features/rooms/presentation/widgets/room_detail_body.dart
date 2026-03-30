import 'package:andespace/core/di/auth_providers.dart';
import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/features/rooms/domain/entities/room_date_availability.dart';
import 'package:andespace/features/rooms/presentation/providers/rooms_providers.dart';
import 'package:andespace/shared/widgets/utilities_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_theme_extension.dart';
import '../../domain/entities/room_search.dart';

class RoomDetailBody extends ConsumerStatefulWidget {
  final RoomSearchItem room;

  const RoomDetailBody({super.key, required this.room});

  @override
  ConsumerState<RoomDetailBody> createState() => _RoomDetailBodyState();
}

class _RoomDetailBodyState extends ConsumerState<RoomDetailBody> {
  late DateTime selectedDate;

  RoomDateAvailability? _liveAvailability;
  bool _isLoadingAvailability = false;
  String? _availabilityError;

  Color _fieldColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface;
  }

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  void initState() {
    super.initState();
    final session = ref.read(sessionControllerProvider);
    selectedDate = session.currentSearch?.date ?? DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDateAvailability();
    });
  }

  Future<void> _loadDateAvailability() async {
    setState(() {
      _isLoadingAvailability = true;
      _availabilityError = null;
    });

    try {
      final useCase = ref.read(fetchRoomDateAvailabilityUseCaseProvider);
      final result = await useCase(
        roomId: widget.room.roomId,
        date: _formatApiDate(selectedDate),
      );

      if (!mounted) return;

      setState(() {
        _liveAvailability = result;
        _isLoadingAvailability = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingAvailability = false;
        _availabilityError = _mapError(e);
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = today.add(const Duration(days: 7));
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: today,
      lastDate: last,
      selectableDayPredicate: (d) {
        final nd = DateTime(d.year, d.month, d.day);
        return !nd.isBefore(today) && !nd.isAfter(last);
      },
      builder: (context, child) {
        final isDark = theme.brightness == Brightness.dark;
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: brand.accentYellow,
              onPrimary: Colors.black, // Texto del círculo seleccionado
              surface: isDark ? _fieldColor(context) : Colors.white,
              onSurface: isDark ? Colors.white : Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: isDark ? brand.accentYellow : Colors.black,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: brand.accentYellow,
              headerForegroundColor: Colors.black,
              backgroundColor: isDark ? _fieldColor(context) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark ? Colors.white12 : Colors.black,
                  width: 1.5,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
    setState(() => selectedDate = picked);
    final session = ref.read(sessionControllerProvider);
    session.updateSearchSelection(
      date: picked,
      startTime: session.currentSearch?.startTime,
      endTime: session.currentSearch?.endTime,
    );
      await _loadDateAvailability();
    }
  }

  void _showInDevelopmentMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$feature is currently in development",
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _onBookPressed() async {
    final authState = ref.read(authControllerProvider);

    if (!authState.hasActiveSession) {
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.createBooking,
      arguments: widget.room,
    );

    if (result != null && mounted) {
      await _loadDateAvailability();
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatApiDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _mapError(Object error) {
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final brand = t.extension<BrandColors>()!;
    final room = widget.room;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.roomId,
                            style: t.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Building: ${room.buildingName ?? room.buildingCode}",
                            style: t.textTheme.bodyMedium,
                          ),
                          Text(
                            "Capacity: ${room.capacity} people",
                            style: t.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    _HeaderIcon(
                      icon: Icons.report_gmailerrorred_outlined,
                      onTap: () => _showInDevelopmentMessage("Reporting"),
                    ),
                    const SizedBox(width: 10),
                    _HeaderIcon(
                      icon: Icons.favorite_border,
                      onTap: () => _showInDevelopmentMessage("Favorites"),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _fieldColor(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isDark(context)
                              ? t.colorScheme.onSurface.withValues(alpha: 0.16)
                              : Colors.black,
                          width: _isDark(context) ? 1 : 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _isDark(context)
                                ? Colors.black.withValues(alpha: 0.18)
                                : Colors.black,
                            blurRadius: _isDark(context) ? 12 : 0,
                            offset: _isDark(context)
                                ? const Offset(0, 4)
                                : const Offset(3, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatDate(selectedDate),
                            style: t.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: t.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: t.colorScheme.onSurface,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    "Availability",
                    style: t.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildAvailabilityScroller(),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    "Utilities",
                    style: t.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildUtilitiesGrid(room, brand),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onBookPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: brand.accentYellow,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: t.brightness == Brightness.light
                      ? const BorderSide(color: Colors.black, width: 2)
                      : BorderSide.none,
                ),
              ).copyWith(overlayColor: WidgetStateProperty.all(Colors.black12)),
              child: Text(
                "Book Room",
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityScroller() {
    final t = Theme.of(context);
    final brand = t.extension<BrandColors>()!;

    if (_isLoadingAvailability) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_availabilityError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            _availabilityError!,
            style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final data = _liveAvailability;
    if (data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "Availability not loaded yet.",
            style: t.textTheme.bodyMedium,
          ),
        ),
      );
    }

    if (data.availableSlots.isEmpty && data.blockedSlots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "No scheduled availability for this date.",
            style: t.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      children: [
        Text(
          _weekdayLabel(selectedDate.weekday),
          style: t.textTheme.labelLarge?.copyWith(
            color: t.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (data.availableSlots.isNotEmpty)
          _buildSlotsSection(
            title: 'Available',
            slots: data.availableSlots,
            cardColor: _isDark(context) ? _fieldColor(context) : Colors.white,
            borderColor: _isDark(context) ? brand.accentYellow : Colors.black,
            textColor: _isDark(context)
                ? t.colorScheme.onSurface
                : Colors.black,
          ),
        if (data.availableSlots.isNotEmpty && data.blockedSlots.isNotEmpty)
          const SizedBox(height: 12),
        if (data.blockedSlots.isNotEmpty)
          _buildSlotsSection(
            title: 'Taken',
            slots: data.blockedSlots,
            cardColor: _isDark(context)
                ? const Color(0xFF2B2B2B)
                : Colors.grey.shade300,
            borderColor: _isDark(context)
                ? t.colorScheme.onSurface.withValues(alpha: 0.20)
                : Colors.grey.shade600,
            textColor: _isDark(context)
                ? t.colorScheme.onSurface
                : Colors.grey.shade800,
          ),
      ],
    );
  }

  Widget _buildSlotsSection({
    required String title,
    required List<RoomDateSlot> slots,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
  }) {
    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: _isDark(context) ? _fieldColor(context) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isDark(context)
                  ? t.colorScheme.onSurface.withValues(alpha: 0.14)
                  : Colors.black.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final slot = slots[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 1.2),
                ),
                child: Center(
                  child: Text(
                    "${slot.start} - ${slot.end}",
                    style: t.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUtilitiesGrid(RoomSearchItem room, BrandColors brand) {
    final t = Theme.of(context);

    if (room.utilities.isEmpty) {
      return Center(
        child: Text("No utilities listed", style: t.textTheme.bodySmall),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: room.utilities.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3.5,
      ),
      itemBuilder: (context, index) {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isDark(context)
                ? _fieldColor(context)
                : brand.softYellow.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isDark(context) ? brand.accentYellow : Colors.black,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              room.utilities[index].toTitleCase(),
              textAlign: TextAlign.center,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _isDark(context)
                    ? t.colorScheme.onSurface
                    : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
      default:
        return 'Sunday';
    }
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIcon({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? _fieldColor(context) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? t.colorScheme.onSurface.withValues(alpha: 0.16)
                : Colors.black,
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black,
              offset: isDark ? const Offset(0, 2) : const Offset(2, 2),
              blurRadius: isDark ? 4 : 0,
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: t.colorScheme.onSurface),
      ),
    );
  }

  Color _fieldColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface;
  }
}
