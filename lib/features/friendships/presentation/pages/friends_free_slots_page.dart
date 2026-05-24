import 'dart:math';

import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/features/friendships/domain/entities/friend.dart';
import 'package:andespace/features/schedule/domain/entities/friends_free_slot.dart';
import 'package:andespace/features/schedule/presentation/providers/schedule_providers.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendsFreeSlotsPage extends ConsumerStatefulWidget {
  const FriendsFreeSlotsPage({super.key, required this.friends});

  final List<Friend> friends;

  @override
  ConsumerState<FriendsFreeSlotsPage> createState() =>
      _FriendsFreeSlotsPageState();
}

class _FriendsFreeSlotsPageState extends ConsumerState<FriendsFreeSlotsPage> {
  late DateTime _referenceDate;
  FriendsFreeSlots? _freeSlots;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _referenceDate = DateTime(now.year, now.month, now.day);
    Future.microtask(_loadFreeSlots);
  }

  Future<void> _loadFreeSlots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final remote = ref.read(scheduleRemoteDataSourceProvider);
      final friendEmails = widget.friends
          .map((friend) => friend.email)
          .toList();
      final weekDays = _buildWeekDays(_referenceDate);
      final models = await Future.wait(
        weekDays.map(
          (day) =>
              remote.getFriendsFreeSlots(friendEmails: friendEmails, date: day),
        ),
      );
      final days = models.map((model) => model.toEntity()).toList();

      if (!mounted) return;

      setState(() {
        _freeSlots = FriendsFreeSlots(
          totalFriends: days.fold<int>(
            widget.friends.length,
            (maxCount, day) => max(maxCount, day.totalFriends),
          ),
          slots: days.expand((day) => day.slots).toList(),
        );
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _freeSlots = null;
        _isLoading = false;
        _errorMessage = _mapFreeSlotsError(error);
      });
    }
  }

  String _mapFreeSlotsError(Object error) {
    return DioErrorMapper.map(
      error,
      fallback: 'Could not load free slots. Pull to retry.',
      onBadResponse: (statusCode, detail) {
        if (detail != null && detail.trim().isNotEmpty) {
          return detail.trim();
        }

        if (statusCode == 400) return 'Select at least one friend.';
        if (statusCode == 401) return 'Please log in again.';
        if (statusCode == 403) {
          return 'One or more friends are not sharing their schedule.';
        }
        if (statusCode == 404) return 'No schedules were found.';

        return 'Could not load free slots. Pull to retry.';
      },
    ).replaceFirst('Exception: ', '');
  }

  void _goToPreviousWeek() {
    setState(() {
      _referenceDate = _referenceDate.subtract(const Duration(days: 7));
    });
    _loadFreeSlots();
  }

  void _goToNextWeek() {
    setState(() {
      _referenceDate = _referenceDate.add(const Duration(days: 7));
    });
    _loadFreeSlots();
  }

  List<DateTime> _buildWeekDays(DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));

    return List<DateTime>.generate(6, (index) {
      final day = weekStart.add(Duration(days: index));
      return DateTime(day.year, day.month, day.day);
    });
  }

  String _formatWeekRange(DateTime date) {
    final days = _buildWeekDays(date);
    final start = days.first;
    final end = days.last;

    return '${start.day}/${start.month} - ${end.day}/${end.month}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      currentTab: AppTab.favorites,
      onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
      body: RefreshIndicator(
        onRefresh: _loadFreeSlots,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Back',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Expanded(
                          child: Text(
                            'Free Slots',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Refresh',
                          onPressed: _isLoading ? null : _loadFreeSlots,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _SelectedFriendsStrip(friends: widget.friends),
                    const SizedBox(height: 12),
                    _WeekSelector(
                      label: _formatWeekRange(_referenceDate),
                      onPreviousWeek: _isLoading ? null : _goToPreviousWeek,
                      onNextWeek: _isLoading ? null : _goToNextWeek,
                    ),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? _FreeSlotsMessage(message: _errorMessage!)
                      : _freeSlots == null || _freeSlots!.slots.isEmpty
                      ? const _FreeSlotsMessage(
                          message: 'No shared free slots were found.',
                        )
                      : _FreeSlotsGrid(freeSlots: _freeSlots!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekSelector extends StatelessWidget {
  const _WeekSelector({
    required this.label,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  final String label;
  final VoidCallback? onPreviousWeek;
  final VoidCallback? onNextWeek;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: _panelBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _gridBorderColor(context)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous week',
            onPressed: onPreviousWeek,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next week',
            onPressed: onNextWeek,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _SelectedFriendsStrip extends StatelessWidget {
  const _SelectedFriendsStrip({required this.friends});

  final List<Friend> friends;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final friend in friends)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.secondary.withValues(alpha: 0.55),
              ),
            ),
            child: Text(
              friend.username,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _FreeSlotsGrid extends StatelessWidget {
  const _FreeSlotsGrid({required this.freeSlots});

  final FriendsFreeSlots freeSlots;

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
        _FreeSlotsLegend(totalFriends: totalFriends),
        const SizedBox(height: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _panelBackground(context),
                border: Border.all(color: _gridBorderColor(context)),
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
                                    timeColumnWidth: _timeColumnWidth,
                                    dayColumnWidth: _dayColumnWidth,
                                    rowHeight: _rowHeight,
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

    return weekdays
        .map((weekday) => _DayInfo(weekday, datesByWeekday[weekday]))
        .toList();
  }

  List<_TimeRange> _buildRows(List<FriendFreeSlot> slots) {
    final boundaries = <int>{};

    for (final slot in slots) {
      final start = _minutesFromTime(slot.startTime);
      final end = _minutesFromTime(slot.endTime);

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
        final slotStart = _minutesFromTime(slot.startTime);
        final slotEnd = _minutesFromTime(slot.endTime);

        return slotStart <= start && slotEnd >= end;
      });

      if (isCovered) {
        rows.add(_TimeRange(_timeFromMinutes(start), _timeFromMinutes(end)));
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

      final slotStart = _minutesFromTime(slot.startTime);
      final slotEnd = _minutesFromTime(slot.endTime);

      for (final row in rows) {
        final rowStart = _minutesFromTime(row.startTime);
        final rowEnd = _minutesFromTime(row.endTime);

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
  const _FreeSlotsLegend({required this.totalFriends});

  final int totalFriends;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          'Overlap',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            fontWeight: FontWeight.w800,
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
        border: Border(bottom: BorderSide(color: _gridBorderColor(context))),
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
                  left: BorderSide(color: _gridBorderColor(context)),
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
                  if (day.dateLabel != null)
                    Text(
                      day.dateLabel!,
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
    required this.timeColumnWidth,
    required this.dayColumnWidth,
    required this.rowHeight,
  });

  final _TimeRange row;
  final List<_DayInfo> days;
  final Map<String, _SlotCellData> cells;
  final int totalFriends;
  final double timeColumnWidth;
  final double dayColumnWidth;
  final double rowHeight;

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
                bottom: BorderSide(color: _gridBorderColor(context)),
              ),
            ),
            child: Text(
              '${_formatTime(row.startTime)}\n${_formatTime(row.endTime)}',
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
  });

  final _SlotCellData? data;
  final int totalFriends;
  final double width;

  @override
  Widget build(BuildContext context) {
    final count = data?.freeCount ?? 0;
    final ratio = totalFriends == 0 ? 0.0 : count / totalFriends;

    return Container(
      width: width,
      height: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: _gridBorderColor(context)),
          bottom: BorderSide(color: _gridBorderColor(context)),
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: count == 0
              ? _emptySlotBackground(context)
              : _freeSlotColor(context, ratio),
          borderRadius: BorderRadius.circular(7),
        ),
        child: count == 0
            ? null
            : Text(
                '$count/$totalFriends',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: _slotTextColor(ratio),
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}

class _FreeSlotsMessage extends StatelessWidget {
  const _FreeSlotsMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _panelBackground(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _gridBorderColor(context)),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _DayInfo {
  const _DayInfo(this.weekday, this.date);

  final int weekday;
  final DateTime? date;

  String get shortLabel {
    return switch (weekday) {
      DateTime.monday => 'Mon',
      DateTime.tuesday => 'Tue',
      DateTime.wednesday => 'Wed',
      DateTime.thursday => 'Thu',
      DateTime.friday => 'Fri',
      DateTime.saturday => 'Sat',
      DateTime.sunday => 'Sun',
      _ => '',
    };
  }

  String? get dateLabel {
    final value = date;
    if (value == null) return null;

    return '${value.day}/${value.month}';
  }
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
  return '$weekday|${_rangeKey(startTime, endTime)}';
}

String _rangeKey(String startTime, String endTime) {
  return '${_normalizeTime(startTime)}-${_normalizeTime(endTime)}';
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

String _formatTime(String raw) {
  final normalized = _normalizeTime(raw);
  if (normalized.length < 5) return raw;

  return normalized.substring(0, 5);
}

String _normalizeTime(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return value;

  final parts = value.split(':');
  if (parts.length < 2) return value;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return value;

  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
}

int _minutesFromTime(String raw) {
  final normalized = _normalizeTime(raw);
  final parts = normalized.split(':');
  if (parts.length < 2) return 0;

  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;

  return hour * 60 + minute;
}

String _timeFromMinutes(int minutes) {
  final hour = (minutes ~/ 60).clamp(0, 23);
  final minute = (minutes % 60).clamp(0, 59);

  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
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

Color _panelBackground(BuildContext context) {
  final theme = Theme.of(context);
  return theme.brightness == Brightness.dark
      ? const Color(0xFF1A1D22)
      : Colors.white;
}

Color _emptySlotBackground(BuildContext context) {
  final theme = Theme.of(context);
  return theme.colorScheme.onSurface.withValues(alpha: 0.04);
}

Color _gridBorderColor(BuildContext context) {
  return Theme.of(context).dividerColor.withValues(alpha: 0.18);
}
