import 'dart:math';

import 'package:andespace/features/friendships/domain/entities/free_slot_selection.dart';
import 'package:andespace/features/friendships/presentation/widgets/friends_free_slots_theme.dart';
import 'package:andespace/features/schedule/domain/entities/friends_free_slot.dart';
import 'package:flutter/material.dart';

class FriendsFreeSlotsGrid extends StatelessWidget {
  const FriendsFreeSlotsGrid({
    super.key,
    required this.referenceDate,
    required this.freeSlots,
    required this.selectedSlotKeys,
    required this.isFindingRooms,
    required this.onSlotToggled,
    required this.onClearSelection,
    required this.onFindRooms,
  });

  final DateTime referenceDate;
  final FriendsFreeSlots freeSlots;
  final Set<String> selectedSlotKeys;
  final bool isFindingRooms;
  final ValueChanged<FreeSlotSelection> onSlotToggled;
  final VoidCallback onClearSelection;
  final VoidCallback onFindRooms;

  static const double _timeColumnWidth = 88;
  static const double _dayColumnWidth = 98;
  static const double _rowHeight = 54;

  @override
  Widget build(BuildContext context) {
    final totalFriends = max(1, freeSlots.totalFriends);
    final days = _buildDays(freeSlots.slots);
    final rows = _buildRows(freeSlots.slots);
    final cellData = _buildCellData(freeSlots.slots, rows);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FreeSlotsLegend(
          totalFriends: totalFriends,
          selectedCount: selectedSlotKeys.length,
          onClearSelection: selectedSlotKeys.isEmpty || isFindingRooms
              ? null
              : onClearSelection,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: friendsFreeSlotsPanelBackground(context),
                border: Border.all(
                  color: friendsFreeSlotsGridBorderColor(context),
                ),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: _timeColumnWidth + days.length * _dayColumnWidth,
                    child: Column(
                      children: [
                        _GridHeader(
                          days: days,
                          timeColumnWidth: _timeColumnWidth,
                          dayColumnWidth: _dayColumnWidth,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                for (final row in rows)
                                  _GridRow(
                                    row: row,
                                    days: days,
                                    cells: cellData,
                                    totalFriends: totalFriends,
                                    selectedSlotKeys: selectedSlotKeys,
                                    timeColumnWidth: _timeColumnWidth,
                                    dayColumnWidth: _dayColumnWidth,
                                    rowHeight: _rowHeight,
                                    onSlotToggled: onSlotToggled,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (selectedSlotKeys.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              style: _findRoomsButtonStyle(context),
              onPressed: isFindingRooms ? null : onFindRooms,
              icon: isFindingRooms
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _findRoomsButtonForeground(context),
                        ),
                      ),
                    )
                  : const Icon(Icons.meeting_room_outlined),
              label: Text(
                selectedSlotKeys.length == 1
                    ? 'Find rooms for 1 slot'
                    : 'Find rooms for ${selectedSlotKeys.length} slots',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<_DayInfo> _buildDays(List<FriendFreeSlot> slots) {
    final discovered = <int>{};
    final datesByWeekday = <int, DateTime>{};

    for (final slot in slots) {
      final weekday = slot.date?.weekday ?? _weekdayIndex(slot.weekday);
      if (weekday == null) continue;

      discovered.add(weekday);
      if (slot.date != null) {
        datesByWeekday.putIfAbsent(weekday, () => slot.date!);
      }
    }

    final weekdays = <int>[
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      if (discovered.contains(DateTime.sunday)) DateTime.sunday,
    ];
    final weekStart = referenceDate.subtract(
      Duration(days: referenceDate.weekday - 1),
    );

    return weekdays
        .map(
          (weekday) => _DayInfo(
            weekday,
            datesByWeekday[weekday] ??
                weekStart.add(Duration(days: weekday - DateTime.monday)),
          ),
        )
        .toList();
  }

  List<_TimeRange> _buildRows(List<FriendFreeSlot> slots) {
    final boundaries = <int>{};

    for (final slot in slots) {
      final start = minutesFromSelectionTime(slot.startTime);
      final end = minutesFromSelectionTime(slot.endTime);

      if (end <= start) continue;

      boundaries
        ..add(start)
        ..add(end);
    }

    final sortedBoundaries = boundaries.toList()..sort();
    final rows = <_TimeRange>[];

    for (var index = 0; index < sortedBoundaries.length - 1; index++) {
      final start = sortedBoundaries[index];
      final end = sortedBoundaries[index + 1];

      if (start == end) continue;

      final isCovered = slots.any((slot) {
        final slotStart = minutesFromSelectionTime(slot.startTime);
        final slotEnd = minutesFromSelectionTime(slot.endTime);

        return slotStart <= start && slotEnd >= end;
      });

      if (isCovered) {
        rows.add(
          _TimeRange(
            selectionTimeFromMinutes(start),
            selectionTimeFromMinutes(end),
          ),
        );
      }
    }

    return rows;
  }

  Map<String, _SlotCellData> _buildCellData(
    List<FriendFreeSlot> slots,
    List<_TimeRange> rows,
  ) {
    final cells = <String, _SlotCellData>{};

    for (final slot in slots) {
      final weekday = slot.date?.weekday ?? _weekdayIndex(slot.weekday);
      if (weekday == null) continue;

      final slotStart = minutesFromSelectionTime(slot.startTime);
      final slotEnd = minutesFromSelectionTime(slot.endTime);

      for (final row in rows) {
        final rowStart = minutesFromSelectionTime(row.startTime);
        final rowEnd = minutesFromSelectionTime(row.endTime);

        if (slotStart > rowStart || slotEnd < rowEnd) continue;

        final key = _cellKey(weekday, row.startTime, row.endTime);
        final existing = cells[key];
        if (existing == null || slot.freeCount > existing.freeCount) {
          cells[key] = _SlotCellData(slot.freeCount);
        }
      }
    }

    return cells;
  }
}

class _FreeSlotsLegend extends StatelessWidget {
  const _FreeSlotsLegend({
    required this.totalFriends,
    required this.selectedCount,
    required this.onClearSelection,
  });

  final int totalFriends;
  final int selectedCount;
  final VoidCallback? onClearSelection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  selectedCount == 0
                      ? 'Overlap'
                      : '$selectedCount selected ${selectedCount == 1 ? 'slot' : 'slots'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (onClearSelection != null) ...[
                const SizedBox(width: 6),
                TextButton(
                  onPressed: onClearSelection,
                  style: TextButton.styleFrom(
                    foregroundColor: friendsFreeSlotsActionOrange(context),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: const Size(0, 34),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    textStyle: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        _LegendPill(label: '1/$totalFriends', ratio: 1 / totalFriends),
        const SizedBox(width: 6),
        _LegendPill(label: '$totalFriends/$totalFriends', ratio: 1),
      ],
    );
  }
}

class _LegendPill extends StatelessWidget {
  const _LegendPill({required this.label, required this.ratio});

  final String label;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: _freeSlotColor(context, ratio),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: _slotTextColor(ratio),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _GridHeader extends StatelessWidget {
  const _GridHeader({
    required this.days,
    required this.timeColumnWidth,
    required this.dayColumnWidth,
  });

  final List<_DayInfo> days;
  final double timeColumnWidth;
  final double dayColumnWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.18),
        border: Border(
          bottom: BorderSide(color: friendsFreeSlotsGridBorderColor(context)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: timeColumnWidth),
          for (final day in days)
            Container(
              width: dayColumnWidth,
              height: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: friendsFreeSlotsGridBorderColor(context),
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.shortLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    day.dateLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.62,
                      ),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GridRow extends StatelessWidget {
  const _GridRow({
    required this.row,
    required this.days,
    required this.cells,
    required this.totalFriends,
    required this.selectedSlotKeys,
    required this.timeColumnWidth,
    required this.dayColumnWidth,
    required this.rowHeight,
    required this.onSlotToggled,
  });

  final _TimeRange row;
  final List<_DayInfo> days;
  final Map<String, _SlotCellData> cells;
  final int totalFriends;
  final Set<String> selectedSlotKeys;
  final double timeColumnWidth;
  final double dayColumnWidth;
  final double rowHeight;
  final ValueChanged<FreeSlotSelection> onSlotToggled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: rowHeight,
      child: Row(
        children: [
          Container(
            width: timeColumnWidth,
            height: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: friendsFreeSlotsGridBorderColor(context),
                ),
              ),
            ),
            child: Text(
              '${formatSelectionTime(row.startTime)}\n'
              '${formatSelectionTime(row.endTime)}',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
          for (final day in days)
            _FreeSlotCell(
              data: cells[_cellKey(day.weekday, row.startTime, row.endTime)],
              totalFriends: totalFriends,
              width: dayColumnWidth,
              selection: FreeSlotSelection(
                date: day.date,
                weekday: day.weekday,
                startTime: row.startTime,
                endTime: row.endTime,
              ),
              isSelected: selectedSlotKeys.contains(
                selectionKey(day.date, row.startTime, row.endTime),
              ),
              onToggled: onSlotToggled,
            ),
        ],
      ),
    );
  }
}

class _FreeSlotCell extends StatelessWidget {
  const _FreeSlotCell({
    required this.data,
    required this.totalFriends,
    required this.width,
    required this.selection,
    required this.isSelected,
    required this.onToggled,
  });

  final _SlotCellData? data;
  final int totalFriends;
  final double width;
  final FreeSlotSelection selection;
  final bool isSelected;
  final ValueChanged<FreeSlotSelection> onToggled;

  @override
  Widget build(BuildContext context) {
    final count = data?.freeCount ?? 0;
    final ratio = totalFriends == 0 ? 0.0 : count / totalFriends;
    final canSelect = count >= totalFriends;
    final slotColor = count == 0
        ? friendsFreeSlotsEmptySlotBackground(context)
        : _freeSlotColor(context, ratio);
    final contentColor = _slotTextColor(ratio);

    return Container(
      width: width,
      height: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: friendsFreeSlotsGridBorderColor(context)),
          bottom: BorderSide(color: friendsFreeSlotsGridBorderColor(context)),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: canSelect ? () => onToggled(selection) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: slotColor,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: count == 0
                ? null
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 120),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            key: const ValueKey('selected'),
                            color: contentColor,
                            size: 22,
                          )
                        : Text(
                            '$count/$totalFriends',
                            key: const ValueKey('count'),
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: contentColor,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _DayInfo {
  const _DayInfo(this.weekday, this.date);

  final int weekday;
  final DateTime date;

  String get shortLabel => weekdayShortLabel(weekday);

  String get dateLabel => '${date.day}/${date.month}';
}

class _TimeRange {
  const _TimeRange(this.startTime, this.endTime);

  final String startTime;
  final String endTime;
}

class _SlotCellData {
  const _SlotCellData(this.freeCount);

  final int freeCount;
}

String _cellKey(int weekday, String startTime, String endTime) {
  return '$weekday|${timeRangeKey(startTime, endTime)}';
}

int? _weekdayIndex(String? weekday) {
  if (weekday == null) return null;

  return switch (weekday.trim().toLowerCase()) {
    'monday' || 'mon' || 'lunes' => DateTime.monday,
    'tuesday' || 'tue' || 'martes' => DateTime.tuesday,
    'wednesday' || 'wed' || 'miercoles' => DateTime.wednesday,
    'thursday' || 'thu' || 'jueves' => DateTime.thursday,
    'friday' || 'fri' || 'viernes' => DateTime.friday,
    'saturday' || 'sat' || 'sabado' => DateTime.saturday,
    'sunday' || 'sun' || 'domingo' => DateTime.sunday,
    _ => null,
  };
}

Color _freeSlotColor(BuildContext context, double ratio) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final clamped = ratio.clamp(0.0, 1.0);
  final low = isDark ? const Color(0xFF1F5F43) : const Color(0xFFB8F2D3);
  final high = isDark ? const Color(0xFF00D47A) : const Color(0xFF00A862);

  return Color.lerp(low, high, clamped)!;
}

Color _slotTextColor(double ratio) {
  return ratio >= 0.72 ? Colors.white : const Color(0xFF062315);
}

ButtonStyle _findRoomsButtonStyle(BuildContext context) {
  final theme = Theme.of(context);
  final background = _findRoomsButtonBackground(context);
  final foreground = _findRoomsButtonForeground(context);

  return FilledButton.styleFrom(
    backgroundColor: background,
    foregroundColor: foreground,
    disabledBackgroundColor: background.withValues(alpha: 0.55),
    disabledForegroundColor: foreground.withValues(alpha: 0.70),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w900,
    ),
  );
}

Color _findRoomsButtonBackground(BuildContext context) {
  return friendsFreeSlotsActionOrange(context);
}

Color _findRoomsButtonForeground(BuildContext context) {
  return Colors.black;
}
