import 'package:andespace/features/rooms/presentation/pages/room_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:andespace/features/rooms/domain/entities/room_search.dart';

class RecommendedRoomsPage extends ConsumerStatefulWidget {
  const RecommendedRoomsPage({
    super.key,
    required this.items,
    this.lastUpdated,
    this.isOffline = false,
    this.description,
    this.emptyMessage,
    this.timeFilterOptions = const [],
  });

  final List<RoomSearchItem> items;
  final DateTime? lastUpdated;
  final bool isOffline;
  final String? description;
  final String? emptyMessage;
  final List<MatchingWindow> timeFilterOptions;

  @override
  ConsumerState<RecommendedRoomsPage> createState() =>
      _RecommendedRoomsPageState();
}

class _RecommendedRoomsPageState extends ConsumerState<RecommendedRoomsPage> {
  final TextEditingController _buildingSearchController =
      TextEditingController();
  final Set<String> _selectedBuildings = {};
  final Set<int> _selectedFloors = {};
  final Set<String> _selectedUtilities = {};
  String? _selectedTimeKey;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _buildingSearchController.addListener(_onFiltersChanged);
  }

  @override
  void dispose() {
    _buildingSearchController
      ..removeListener(_onFiltersChanged)
      ..dispose();
    super.dispose();
  }

  void _onFiltersChanged() {
    setState(() {});
  }

  void _toggleBuilding(String buildingCode) {
    setState(() {
      if (_selectedBuildings.contains(buildingCode)) {
        _selectedBuildings.remove(buildingCode);
      } else {
        _selectedBuildings.add(buildingCode);
      }
    });
  }

  void _toggleFloor(int floor) {
    setState(() {
      if (_selectedFloors.contains(floor)) {
        _selectedFloors.remove(floor);
      } else {
        _selectedFloors.add(floor);
      }
    });
  }

  void _toggleUtility(String utility) {
    setState(() {
      if (_selectedUtilities.contains(utility)) {
        _selectedUtilities.remove(utility);
      } else {
        _selectedUtilities.add(utility);
      }
    });
  }

  void _selectTime(String? key) {
    setState(() => _selectedTimeKey = key);
  }

  void _clearFilters() {
    setState(() {
      _selectedBuildings.clear();
      _selectedFloors.clear();
      _selectedUtilities.clear();
      _selectedTimeKey = null;
      _buildingSearchController.clear();
    });
  }

  void _toggleFilters() {
    setState(() => _showFilters = !_showFilters);
  }

  List<RoomSearchItem> get _filteredItems {
    final buildingQuery = _buildingSearchController.text.trim().toLowerCase();

    return widget.items.where((room) {
      final buildingMatches =
          _selectedBuildings.isEmpty ||
          _selectedBuildings.contains(room.buildingCode);
      if (!buildingMatches) return false;

      if (buildingQuery.isNotEmpty &&
          !_matchesBuildingQuery(room, buildingQuery)) {
        return false;
      }

      final floor = _inferFloor(room);
      if (_selectedFloors.isNotEmpty &&
          (floor == null || !_selectedFloors.contains(floor))) {
        return false;
      }

      if (_selectedUtilities.isNotEmpty) {
        final roomUtilities = room.utilities.toSet();
        if (!_selectedUtilities.every(roomUtilities.contains)) return false;
      }

      final timeKey = _selectedTimeKey;
      if (timeKey != null && !_roomMatchesTime(room, timeKey)) return false;

      return true;
    }).toList();
  }

  bool _matchesBuildingQuery(RoomSearchItem room, String query) {
    return room.buildingCode.toLowerCase().contains(query) ||
        (room.buildingName ?? '').toLowerCase().contains(query) ||
        room.roomId.toLowerCase().contains(query);
  }

  bool _roomMatchesTime(RoomSearchItem room, String selectedTimeKey) {
    final selected = _timeOptionsByKey[selectedTimeKey];
    if (selected == null) return true;

    return room.matchingWindows.any(
      (window) =>
          _minutesFromTime(window.start) <= _minutesFromTime(selected.start) &&
          _minutesFromTime(window.end) >= _minutesFromTime(selected.end),
    );
  }

  Map<String, MatchingWindow> get _timeOptionsByKey {
    return {
      for (final window in _timeOptions)
        _timeKey(window.start, window.end): window,
    };
  }

  List<MatchingWindow> get _timeOptions {
    final source = widget.timeFilterOptions.isNotEmpty
        ? widget.timeFilterOptions
        : widget.items.expand((room) => room.matchingWindows);
    final unique = <String, MatchingWindow>{};

    for (final window in source) {
      final key = _timeKey(window.start, window.end);
      unique[key] = window;
    }

    return unique.values.toList()..sort((a, b) => a.start.compareTo(b.start));
  }

  List<_BuildingFilterOption> get _buildingOptions {
    final options = <String, _BuildingFilterOption>{};

    for (final room in widget.items) {
      options.putIfAbsent(
        room.buildingCode,
        () => _BuildingFilterOption(
          code: room.buildingCode,
          label: room.buildingName == null || room.buildingName!.trim().isEmpty
              ? room.buildingCode
              : '${room.buildingCode} - ${room.buildingName}',
        ),
      );
    }

    return options.values.toList()..sort((a, b) => a.code.compareTo(b.code));
  }

  List<int> get _floorOptions {
    return widget.items.map(_inferFloor).whereType<int>().toSet().toList()
      ..sort();
  }

  List<String> get _utilityOptions {
    return widget.items.expand((room) => room.utilities).toSet().toList()
      ..sort();
  }

  bool get _hasActiveFilters {
    return _selectedBuildings.isNotEmpty ||
        _selectedFloors.isNotEmpty ||
        _selectedUtilities.isNotEmpty ||
        _selectedTimeKey != null ||
        _buildingSearchController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Recommended Rooms')),
      body: Column(
        children: [
          if (widget.isOffline && widget.lastUpdated != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _CachedRecommendationsBanner(
                lastUpdated: widget.lastUpdated!,
              ),
            ),
          if (widget.items.isNotEmpty ||
              (widget.description != null &&
                  widget.description!.trim().isNotEmpty))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _RecommendationsHeader(
                description: widget.description,
                filteredCount: filteredItems.length,
                totalCount: widget.items.length,
                isFilterOpen: _showFilters,
                hasActiveFilters: _hasActiveFilters,
                onToggleFilters: _toggleFilters,
              ),
            ),
          if (widget.items.isNotEmpty && _showFilters)
            _RecommendationFilters(
              buildingSearchController: _buildingSearchController,
              buildingOptions: _buildingOptions,
              selectedBuildings: _selectedBuildings,
              timeOptions: _timeOptions,
              selectedTimeKey: _selectedTimeKey,
              floorOptions: _floorOptions,
              selectedFloors: _selectedFloors,
              utilityOptions: _utilityOptions,
              selectedUtilities: _selectedUtilities,
              filteredCount: filteredItems.length,
              totalCount: widget.items.length,
              hasActiveFilters: _hasActiveFilters,
              onBuildingToggled: _toggleBuilding,
              onTimeSelected: _selectTime,
              onFloorToggled: _toggleFloor,
              onUtilityToggled: _toggleUtility,
              onClearFilters: _clearFilters,
            ),
          Expanded(
            child: widget.items.isEmpty
                ? _EmptyRecommendationsView(
                    isOffline: widget.isOffline,
                    emptyMessage: widget.emptyMessage,
                  )
                : filteredItems.isEmpty
                ? const _NoFilteredRoomsView()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final room = filteredItems[index];
                      return _RecommendedRoomCard(room: room);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationFilters extends StatelessWidget {
  const _RecommendationFilters({
    required this.buildingSearchController,
    required this.buildingOptions,
    required this.selectedBuildings,
    required this.timeOptions,
    required this.selectedTimeKey,
    required this.floorOptions,
    required this.selectedFloors,
    required this.utilityOptions,
    required this.selectedUtilities,
    required this.filteredCount,
    required this.totalCount,
    required this.hasActiveFilters,
    required this.onBuildingToggled,
    required this.onTimeSelected,
    required this.onFloorToggled,
    required this.onUtilityToggled,
    required this.onClearFilters,
  });

  final TextEditingController buildingSearchController;
  final List<_BuildingFilterOption> buildingOptions;
  final Set<String> selectedBuildings;
  final List<MatchingWindow> timeOptions;
  final String? selectedTimeKey;
  final List<int> floorOptions;
  final Set<int> selectedFloors;
  final List<String> utilityOptions;
  final Set<String> selectedUtilities;
  final int filteredCount;
  final int totalCount;
  final bool hasActiveFilters;
  final ValueChanged<String> onBuildingToggled;
  final ValueChanged<String?> onTimeSelected;
  final ValueChanged<int> onFloorToggled;
  final ValueChanged<String> onUtilityToggled;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxFilterHeight = MediaQuery.sizeOf(context).height * 0.46;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.18)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxFilterHeight),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$filteredCount of $totalCount rooms',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (hasActiveFilters)
                    TextButton(
                      onPressed: onClearFilters,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 34),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Clear'),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: buildingSearchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 20),
                  hintText: 'Type a building or room',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  suffixIcon: buildingSearchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear building search',
                          onPressed: buildingSearchController.clear,
                          icon: const Icon(Icons.close, size: 18),
                        ),
                ),
              ),
              if (buildingOptions.isNotEmpty) ...[
                const SizedBox(height: 12),
                _FilterSection(
                  label: 'Buildings',
                  children: [
                    for (final option in buildingOptions)
                      FilterChip(
                        label: Text(option.label),
                        selected: selectedBuildings.contains(option.code),
                        onSelected: (_) => onBuildingToggled(option.code),
                      ),
                  ],
                ),
              ],
              if (timeOptions.isNotEmpty) ...[
                const SizedBox(height: 12),
                _FilterSection(
                  label: 'Time',
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: selectedTimeKey == null,
                      onSelected: (_) => onTimeSelected(null),
                    ),
                    for (final window in timeOptions)
                      ChoiceChip(
                        label: Text(
                          '${_formatHour(window.start)} - ${_formatHour(window.end)}',
                        ),
                        selected:
                            selectedTimeKey ==
                            _timeKey(window.start, window.end),
                        onSelected: (_) =>
                            onTimeSelected(_timeKey(window.start, window.end)),
                      ),
                  ],
                ),
              ],
              if (floorOptions.isNotEmpty) ...[
                const SizedBox(height: 12),
                _FilterSection(
                  label: 'Floor',
                  children: [
                    for (final floor in floorOptions)
                      FilterChip(
                        label: Text('Floor $floor'),
                        selected: selectedFloors.contains(floor),
                        onSelected: (_) => onFloorToggled(floor),
                      ),
                  ],
                ),
              ],
              if (utilityOptions.isNotEmpty) ...[
                const SizedBox(height: 12),
                _FilterSection(
                  label: 'Utilities',
                  children: [
                    for (final utility in utilityOptions)
                      FilterChip(
                        label: Text(_formatUtility(utility)),
                        selected: selectedUtilities.contains(utility),
                        onSelected: (_) => onUtilityToggled(utility),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

class _BuildingFilterOption {
  const _BuildingFilterOption({required this.code, required this.label});

  final String code;
  final String label;
}

class _RecommendationsHeader extends StatelessWidget {
  const _RecommendationsHeader({
    required this.description,
    required this.filteredCount,
    required this.totalCount,
    required this.isFilterOpen,
    required this.hasActiveFilters,
    required this.onToggleFilters,
  });

  final String? description;
  final int filteredCount;
  final int totalCount;
  final bool isFilterOpen;
  final bool hasActiveFilters;
  final VoidCallback onToggleFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDescription =
        description != null && description!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hasDescription
                  ? description!
                  : '$filteredCount of $totalCount rooms',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _FilterIconButton(
            isActive: isFilterOpen || hasActiveFilters,
            onPressed: onToggleFilters,
          ),
        ],
      ),
    );
  }
}

class _FilterIconButton extends StatelessWidget {
  const _FilterIconButton({required this.isActive, required this.onPressed});

  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = isActive
        ? theme.colorScheme.secondary.withValues(alpha: 0.22)
        : theme.cardColor.withValues(alpha: 0.86);
    final iconColor = isActive
        ? theme.colorScheme.secondary
        : theme.colorScheme.onSurface;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/filters.svg',
              width: 21,
              height: 21,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              semanticsLabel: 'Filters',
            ),
          ),
        ),
      ),
    );
  }
}

class _CachedRecommendationsBanner extends StatelessWidget {
  const _CachedRecommendationsBanner({required this.lastUpdated});

  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing last available recommendations. Last updated: ${_formatTimeAgo(lastUpdated)}. Availability may have changed.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} days ago';
  }
}

class _EmptyRecommendationsView extends StatelessWidget {
  const _EmptyRecommendationsView({
    required this.isOffline,
    required this.emptyMessage,
  });

  final bool isOffline;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconBackground = isOffline
        ? theme.colorScheme.secondary
        : theme.colorScheme.secondary.withValues(alpha: 0.14);
    final iconColor = isOffline
        ? theme.colorScheme.onSecondary
        : theme.colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOffline
                    ? Icons.wifi_off_rounded
                    : Icons.meeting_room_outlined,
                size: 40,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isOffline ? 'Internet required' : 'No recommendations found',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isOffline
                  ? 'Connect to the internet to find room recommendations for your schedule.'
                  : emptyMessage ??
                        'No recommended rooms were found for this day.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoFilteredRoomsView extends StatelessWidget {
  const _NoFilteredRoomsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_alt_off_outlined,
              size: 52,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 12),
            Text(
              'No rooms match these filters',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try clearing one filter or typing a different building.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedRoomCard extends StatelessWidget {
  const _RecommendedRoomCard({required this.room});

  final RoomSearchItem room;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = room.roomId.isNotEmpty
        ? room.roomId
        : '${room.buildingCode} ${room.roomNumber}'.trim();

    final subtitle = room.buildingName ?? room.buildingCode;
    final slotLabel = _buildSlotLabel(room);
    final distanceLabel = _buildDistanceLabel(room.distanceSeconds);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: const RouteSettings(name: 'room_detail'),
              builder: (_) => RoomDetailPage(room: room),
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.18),
            ),
            borderRadius: BorderRadius.circular(18),
            color: theme.cardColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(
                        alpha: 0.16,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.meeting_room_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 10),
              Text(subtitle, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (slotLabel != null)
                    _InfoChip(label: slotLabel, icon: Icons.schedule_outlined),
                  _InfoChip(
                    label: 'Capacity ${room.capacity}',
                    icon: Icons.people_outline,
                  ),
                  if (distanceLabel != null)
                    _InfoChip(
                      label: distanceLabel,
                      icon: Icons.directions_walk_outlined,
                    ),
                ],
              ),
              if (room.utilities.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: room.utilities
                      .map((utility) => _TagChip(label: utility))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _buildSlotLabel(RoomSearchItem room) {
    if (room.matchingWindows.isEmpty) return null;

    final first = room.matchingWindows.first;
    final start = _formatHour(first.start);
    final end = _formatHour(first.end);

    if (start == null || end == null) return null;
    return '$start - $end';
  }

  String? _buildDistanceLabel(double? secondsOrDistance) {
    if (secondsOrDistance == null) return null;

    final minutes = (secondsOrDistance / 60).round();
    if (minutes <= 0) return 'Very close';
    if (minutes == 1) return '1 min away';
    return '$minutes min away';
  }

  String? _formatHour(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    final parts = raw.split(':');
    if (parts.length < 2) return raw;

    final hh = parts[0].padLeft(2, '0');
    final mm = parts[1].padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: theme.cardColor,
      side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.18)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

int? _inferFloor(RoomSearchItem room) {
  final roomNumber = room.roomNumber.trim();
  if (roomNumber.isNotEmpty && RegExp(r'^\d').hasMatch(roomNumber)) {
    return int.tryParse(roomNumber[0]);
  }

  final parts = room.roomId.trim().split(RegExp(r'\s+'));
  if (parts.length < 2 || parts.last.isEmpty) return null;

  final first = parts.last[0];
  if (!RegExp(r'\d').hasMatch(first)) return null;
  return int.tryParse(first);
}

String _timeKey(String start, String end) {
  return '${_formatHour(start)}-${_formatHour(end)}';
}

int _minutesFromTime(String raw) {
  final normalized = _formatHour(raw);
  final parts = normalized.split(':');
  if (parts.length < 2) return 0;

  return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
}

String _formatHour(String raw) {
  if (raw.isEmpty) return raw;

  final parts = raw.split(':');
  if (parts.length < 2) return raw;

  final hh = parts[0].padLeft(2, '0');
  final mm = parts[1].padLeft(2, '0');
  return '$hh:$mm';
}

String _formatUtility(String raw) {
  return raw
      .split('_')
      .map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      })
      .join(' ');
}
