import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/features/friendships/domain/entities/friend.dart';
import 'package:andespace/features/schedule/data/mappers/weekly_schedule_mapper.dart';
import 'package:andespace/features/schedule/domain/entities/schedule_occurrence.dart';
import 'package:andespace/features/schedule/domain/entities/weekly_schedule.dart';
import 'package:andespace/features/schedule/presentation/providers/schedule_providers.dart';
import 'package:andespace/features/schedule/presentation/widgets/day_column.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendSchedulePage extends ConsumerStatefulWidget {
  const FriendSchedulePage({super.key, required this.friend});

  final Friend friend;

  @override
  ConsumerState<FriendSchedulePage> createState() => _FriendSchedulePageState();
}

class _FriendSchedulePageState extends ConsumerState<FriendSchedulePage> {
  late DateTime _referenceDate;
  WeeklySchedule? _schedule;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _referenceDate = DateTime(now.year, now.month, now.day);
    Future.microtask(_loadSchedule);
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final remote = ref.read(scheduleRemoteDataSourceProvider);
      final model = await remote.getFriendWeeklySchedule(
        friendEmail: widget.friend.email,
        date: _referenceDate,
      );

      if (!mounted) return;

      setState(() {
        _schedule = WeeklyScheduleMapper.toEntity(model);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _schedule = null;
        _isLoading = false;
        _errorMessage = _mapScheduleError(error);
      });
    }
  }

  void _goToPreviousWeek() {
    setState(() {
      _referenceDate = _referenceDate.subtract(const Duration(days: 7));
    });
    _loadSchedule();
  }

  void _goToNextWeek() {
    setState(() {
      _referenceDate = _referenceDate.add(const Duration(days: 7));
    });
    _loadSchedule();
  }

  String _mapScheduleError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final detail = _extractDetail(error.response?.data);

      if (statusCode == 403) {
        return '${widget.friend.username} does not share their schedule.';
      }

      if (statusCode == 404) {
        return '${widget.friend.username} does not have a schedule yet.';
      }

      if (detail != null && detail.trim().isNotEmpty) {
        return detail.trim();
      }

      if (error.response == null) {
        return 'Could not load ${widget.friend.username}\'s schedule. Check your connection.';
      }
    }

    return 'Could not load ${widget.friend.username}\'s schedule.';
  }

  String? _extractDetail(Object? data) {
    if (data is Map) {
      final detail = data['detail'];
      if (detail != null) return detail.toString();
    }
    return null;
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatWeekRange(DateTime start, DateTime end) {
    return '${start.day} of ${_monthName(start.month)} - ${end.day} of ${_monthName(end.month)}';
  }

  List<_FriendScheduleDay> _buildWeekDays(WeeklySchedule schedule) {
    final grouped = <DateTime, List<ScheduleOccurrence>>{};

    for (final occurrence in schedule.occurrences) {
      if (occurrence.date.weekday == DateTime.sunday) continue;

      final key = DateTime(
        occurrence.date.year,
        occurrence.date.month,
        occurrence.date.day,
      );

      grouped.putIfAbsent(key, () => <ScheduleOccurrence>[]).add(occurrence);
    }

    return List<_FriendScheduleDay>.generate(6, (index) {
      final day = schedule.weekStart.add(Duration(days: index));
      final key = DateTime(day.year, day.month, day.day);
      final occurrences = grouped[key] ?? const <ScheduleOccurrence>[];

      return _FriendScheduleDay(day: key, occurrences: occurrences);
    });
  }

  @override
  Widget build(BuildContext context) {
    final schedule = _schedule;

    return AppScaffold(
      currentTab: AppTab.favorites,
      onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
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
                    '${widget.friend.username}\'s schedule',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (schedule != null) ...[
              _FriendWeekHeader(
                label: _formatWeekRange(schedule.weekStart, schedule.weekEnd),
                onPreviousWeek: _goToPreviousWeek,
                onNextWeek: _goToNextWeek,
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? _FriendScheduleMessage(message: _errorMessage!)
                    : schedule == null
                    ? const SizedBox.shrink()
                    : _FriendWeeklyCalendar(
                        days: _buildWeekDays(schedule),
                        selectedDate: _referenceDate,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendWeeklyCalendar extends StatelessWidget {
  const _FriendWeeklyCalendar({required this.days, required this.selectedDate});

  final List<_FriendScheduleDay> days;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final dayData in days)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: DayColumn(
                  day: dayData.day,
                  occurrences: dayData.occurrences,
                  selectedDate: selectedDate,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FriendWeekHeader extends StatelessWidget {
  const _FriendWeekHeader({
    required this.label,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  final String label;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: .18)),
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
                fontWeight: FontWeight.w700,
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

class _FriendScheduleMessage extends StatelessWidget {
  const _FriendScheduleMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withValues(alpha: .18)),
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

class _FriendScheduleDay {
  const _FriendScheduleDay({required this.day, required this.occurrences});

  final DateTime day;
  final List<ScheduleOccurrence> occurrences;
}
