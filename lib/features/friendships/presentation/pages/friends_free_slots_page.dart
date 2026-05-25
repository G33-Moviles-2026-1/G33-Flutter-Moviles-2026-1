import 'dart:math';

import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/core/utils/date_time_utils.dart';
import 'package:andespace/features/friendships/domain/entities/friend.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/rooms/domain/usecases/search_rooms_exceptions.dart';
import 'package:andespace/features/rooms/presentation/providers/rooms_providers.dart';
import 'package:andespace/features/schedule/domain/entities/friends_free_slot.dart';
import 'package:andespace/features/schedule/presentation/pages/recommended_rooms_page.dart';
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
  final Map<String, _FreeSlotSelection> _selectedSlots = {};
  String? _errorMessage;
  bool _isLoading = true;
  bool _isFindingRooms = false;

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
      _selectedSlots.clear();
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
      _selectedSlots.clear();
    });
    _loadFreeSlots();
  }

  void _goToNextWeek() {
    setState(() {
      _referenceDate = _referenceDate.add(const Duration(days: 7));
      _selectedSlots.clear();
    });
    _loadFreeSlots();
  }

  void _toggleSlot(_FreeSlotSelection slot) {
    setState(() {
      if (_selectedSlots.containsKey(slot.key)) {
        _selectedSlots.remove(slot.key);
      } else {
        _selectedSlots[slot.key] = slot;
      }
    });
  }

  void _clearSelectedSlots() {
    setState(_selectedSlots.clear);
  }

  Future<void> _findRoomsForSelectedSlots() async {
    if (_selectedSlots.isEmpty || _isFindingRooms) return;

    setState(() => _isFindingRooms = true);

    try {
      final repository = ref.read(roomRepositoryProvider);
      final selections = _selectedSlots.values.toList()
        ..sort(_compareSelections);

      final responses = await Future.wait(
        selections.map((slot) {
          return repository.searchRooms(
            RoomSearchRequest(
              roomPrefixes: const [],
              date: DateTimeUtils.toApiDate(slot.date),
              since: slot.startTime,
              until: slot.endTime,
              buildingCodes: const [],
              utilities: const [],
              nearMe: false,
              userLocation: null,
              limit: 20,
              offset: 0,
            ),
          );
        }),
      );

      if (!mounted) return;

      final rooms = _mergeRoomResults(responses.expand((r) => r.items));
      final selectedLabel = selections.map((slot) => slot.label).join(', ');

      await Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: 'friends_free_slots_rooms'),
          builder: (_) => RecommendedRoomsPage(
            items: rooms,
            description: 'Selected slots: $selectedLabel',
            emptyMessage: 'No rooms were found for the selected free slots.',
            timeFilterOptions: _mergeTimeFilterOptions(selections),
          ),
        ),
      );
    } on SearchRoomsConnectivityException {
      _showFindRoomsError(
        'No internet connection. Please check your connection and try again.',
      );
    } catch (error) {
      _showFindRoomsError(_mapFindRoomsError(error));
    } finally {
      if (mounted) {
        setState(() => _isFindingRooms = false);
      }
    }
  }

  void _showFindRoomsError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _mapFindRoomsError(Object error) {
    return DioErrorMapper.map(
      error,
      fallback: 'Could not find rooms for the selected slots.',
      onBadResponse: (statusCode, detail) {
        if (detail != null && detail.trim().isNotEmpty) {
          return detail.trim();
        }

        if (statusCode >= 500) {
          return 'The server is currently unavailable. Please try again later.';
        }

        return 'Could not find rooms for the selected slots.';
      },
    ).replaceFirst('Exception: ', '');
  }

  int _compareSelections(_FreeSlotSelection a, _FreeSlotSelection b) {
    final dayComparison = a.date.compareTo(b.date);
    if (dayComparison != 0) return dayComparison;

    return _minutesFromTime(
      a.startTime,
    ).compareTo(_minutesFromTime(b.startTime));
  }

  List<RoomSearchItem> _mergeRoomResults(Iterable<RoomSearchItem> rooms) {
    final byRoomId = <String, RoomSearchItem>{};
    final windowsByRoomId = <String, Map<String, MatchingWindow>>{};

    for (final room in rooms) {
      final key = room.roomId.isNotEmpty
          ? room.roomId
          : '${room.buildingCode}-${room.roomNumber}';
      final existing = byRoomId[key];

      if (existing == null || room.reliability > existing.reliability) {
        byRoomId[key] = room;
      }

      final windows = windowsByRoomId.putIfAbsent(key, () => {});
      for (final window in room.matchingWindows) {
        windows['${window.start}-${window.end}'] = window;
      }
    }

    return byRoomId.entries.map((entry) {
      final room = entry.value;
      final windows = windowsByRoomId[entry.key]!.values.toList()
        ..sort((a, b) => a.start.compareTo(b.start));

      return RoomSearchItem(
        roomId: room.roomId,
        buildingCode: room.buildingCode,
        buildingName: room.buildingName,
        roomNumber: room.roomNumber,
        capacity: room.capacity,
        reliability: room.reliability,
        utilities: room.utilities,
        distanceSeconds: room.distanceSeconds,
        matchingWindows: windows,
      );
    }).toList()..sort((a, b) {
      final reliability = b.reliability.compareTo(a.reliability);
      if (reliability != 0) return reliability;
      return a.roomId.compareTo(b.roomId);
    });
  }

  List<MatchingWindow> _mergeTimeFilterOptions(
    Iterable<_FreeSlotSelection> selections,
  ) {
    final windows = <String, MatchingWindow>{};

    for (final slot in selections) {
      final key = _rangeKey(slot.startTime, slot.endTime);
      windows[key] = MatchingWindow(start: slot.startTime, end: slot.endTime);
    }

    return windows.values.toList()..sort((a, b) => a.start.compareTo(b.start));
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
                      : _FreeSlotsGrid(
                          referenceDate: _referenceDate,
                          freeSlots: _freeSlots!,
                          selectedSlotKeys: _selectedSlots.keys.toSet(),
                          isFindingRooms: _isFindingRooms,
                          onSlotToggled: _toggleSlot,
                          onClearSelection: _clearSelectedSlots,
                          onFindRooms: _findRoomsForSelectedSlots,
                        ),
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
  const _FreeSlotsGrid({
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
  final ValueChanged<_FreeSlotSelection> onSlotToggled;
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
                    foregroundColor: _appActionOrange(context),
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
  final ValueChanged<_FreeSlotSelection> onSlotToggled;

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
              selection: _FreeSlotSelection(
                date: day.date,
                weekday: day.weekday,
                startTime: row.startTime,
                endTime: row.endTime,
              ),
              isSelected: selectedSlotKeys.contains(
                _selectionKey(day.date, row.startTime, row.endTime),
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
  final _FreeSlotSelection selection;
  final bool isSelected;
  final ValueChanged<_FreeSlotSelection> onToggled;

  @override
  Widget build(BuildContext context) {
    final count = data?.freeCount ?? 0;
    final ratio = totalFriends == 0 ? 0.0 : count / totalFriends;
    final canSelect = count >= totalFriends;
    final slotColor = count == 0
        ? _emptySlotBackground(context)
        : _freeSlotColor(context, ratio);
    final contentColor = _slotTextColor(ratio);

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

class _FreeSlotSelection {
  const _FreeSlotSelection({
    required this.date,
    required this.weekday,
    required this.startTime,
    required this.endTime,
  });

  final DateTime date;
  final int weekday;
  final String startTime;
  final String endTime;

  String get key => _selectionKey(date, startTime, endTime);

  String get label {
    return '${_weekdayShortLabel(weekday)} ${date.day}/${date.month} '
        '${_formatTime(startTime)}-${_formatTime(endTime)}';
  }
}

String _selectionKey(DateTime date, String startTime, String endTime) {
  return '${date.year}-${date.month}-${date.day}|'
      '${_rangeKey(startTime, endTime)}';
}

String _weekdayShortLabel(int weekday) {
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
  final DateTime date;

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
  return _appActionOrange(context);
}

Color _findRoomsButtonForeground(BuildContext context) {
  return Colors.black;
}

Color _appActionOrange(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFFFA500)
      : const Color(0xFFFCBD00);
}
