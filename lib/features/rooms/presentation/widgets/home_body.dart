import 'dart:convert';

import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/rooms/presentation/controllers/home_search_state.dart';
import 'package:andespace/features/rooms/presentation/providers/homepage_providers.dart';
import 'package:andespace/shared/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeBody extends ConsumerStatefulWidget {
  const HomeBody({super.key});

  @override
  ConsumerState<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends ConsumerState<HomeBody> {
  final _roomInputCtrl = TextEditingController();
  final _buildingCodesCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _since;
  TimeOfDay? _until;
  bool _closeToMe = true;
  final Set<String> _selectedUtilities = <String>{};

  static const Map<String, String> _utilityLabels = {
    'blackout': 'Blackout',
    'power_outlet': 'Power outlet',
    'television': 'Television',
    'interactive_classroom': 'Interactive classroom',
    'mobile_whiteboards': 'Mobile whiteboards',
    'computer': 'Computer',
    'videobeam': 'Videobeam',
  };

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _selectedDate = DateTime.now();
    _since = now;
    _until = _addMinutes(now, 90);
  }

  @override
  void dispose() {
    _roomInputCtrl.dispose();
    _buildingCodesCtrl.dispose();
    super.dispose();
  }

  TimeOfDay _addMinutes(TimeOfDay t, int minutesToAdd) {
    final totalMinutes = t.hour * 60 + t.minute + minutesToAdd;
    final normalized = totalMinutes % (24 * 60);
    final h = normalized ~/ 60;
    final m = normalized % 60;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> _pickTime({required bool isSince}) async {
    final fallback = TimeOfDay.now();
    final initial = isSince
        ? (_since ?? fallback)
        : (_until ?? _addMinutes(fallback, 90));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isSince ? 'Select start time' : 'Select end time',
    );

    if (picked == null) return;

    setState(() {
      if (isSince) {
        _since = picked;
      } else {
        _until = picked;
      }
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = firstDate.add(const Duration(days: 7));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select search date',
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: true);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  void _openFiltersSheet() {
    ref.read(homeSearchControllerProvider.notifier).onFiltersOpened();

    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filters', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _buildingCodesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Building codes (comma separated)',
                        hintText: 'ML, SD, RGD',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Utilities', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ..._utilityLabels.entries.map(
                      (entry) => CheckboxListTile(
                        value: _selectedUtilities.contains(entry.key),
                        title: Text(entry.value),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (checked) {
                          setState(() {
                            if (checked ?? false) {
                              _selectedUtilities.add(entry.key);
                            } else {
                              _selectedUtilities.remove(entry.key);
                            }
                          });
                          modalSetState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onSearch() {
    ref
        .read(homeSearchControllerProvider.notifier)
        .submitSearch(
          rawRoomInput: _roomInputCtrl.text,
          rawBuildingCodesInput: _buildingCodesCtrl.text,
          selectedDate: _selectedDate,
          since: _since,
          until: _until,
          selectedUtilities: _selectedUtilities,
          nearMe: _closeToMe,
          offset: 0,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<HomeSearchState>(homeSearchControllerProvider, (previous, next) {
      if (next.status == HomeSearchStatus.success && next.response != null) {
        Navigator.pushNamed(context, AppRoutes.results);
      }

      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;

      if (nextError != null && nextError != previousError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(nextError)));
      }
    });

    final state = ref.watch(homeSearchControllerProvider);
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;
    final response = state.response;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 6),
          Text(
            'Where do you\nwant to go?',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: 34,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _CardField(
                  child: TextField(
                    controller: _roomInputCtrl,
                    style: theme.textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: 'Classroom e.g. ML 201, ML 5, ML',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _SquareIconButton(
                tooltip: 'Filters',
                svgAsset: 'assets/icons/filters.svg',
                onPressed: _openFiltersSheet,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DateBox(value: _formatDate(_selectedDate), onTap: _pickDate),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimeBox(
                  label: 'Since',
                  value: _formatTime(_since),
                  onTap: () => _pickTime(isSince: true),
                  onClear: _since == null
                      ? null
                      : () => setState(() => _since = null),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TimeBox(
                  label: 'Until',
                  value: _formatTime(_until),
                  onTap: () => _pickTime(isSince: false),
                  onClear: _until == null
                      ? null
                      : () => setState(() => _until = null),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/location.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Close to me',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              Checkbox(
                value: _closeToMe,
                onChanged: state.isLoading
                    ? null
                    : (value) => setState(() => _closeToMe = value ?? false),
                activeColor: brand.accentYellow,
                checkColor: theme.colorScheme.onSecondary,
                side: BorderSide(
                  color: theme.colorScheme.onSurface,
                  width: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: _CtaButton(
              label: state.isLoading ? 'Searching...' : 'Search',
              onPressed: state.isLoading ? null : _onSearch,
            ),
          ),
          if (response != null) ...[
            const SizedBox(height: 18),
            _DebugResponseCard(response: response),
          ],
        ],
      ),
    );
  }
}

class _DebugResponseCard extends StatelessWidget {
  const _DebugResponseCard({required this.response});

  final RoomSearchResponse response;

  @override
  Widget build(BuildContext context) {
    final pretty = const JsonEncoder.withIndent('  ').convert(response.toMap());
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Temporary raw response', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Total: ${response.total}'),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: SingleChildScrollView(
              child: SelectionArea(
                child: Text(
                  pretty,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  const _CardField({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
            color: theme.brightness == Brightness.dark
                ? const Color(0x14000000)
                : const Color(0x22000000),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.svgAsset,
    required this.onPressed,
    required this.tooltip,
  });

  final String svgAsset;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: SvgPicture.asset(
              svgAsset,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.onSurface,
                BlendMode.srcIn,
              ),
              semanticsLabel: tooltip,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox({required this.value, required this.onTap});

  final String value;
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Text(
                'Date',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.calendar_today_outlined, size: 18),
              const SizedBox(width: 8),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (onClear != null)
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(Icons.close, size: 18),
                ),
              if (onClear != null) const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/icons/clock.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: brand.accentYellow,
        foregroundColor: theme.colorScheme.onSecondary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.onSurface, width: 1.4),
        ),
        textStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Text(label),
    );
  }
}


class CompactSearchForm extends StatelessWidget {
  final TextEditingController roomCtrl;
  final VoidCallback onSearch;
  final VoidCallback onOpenFilters;
  final bool isLoading;

  const CompactSearchForm({
    super.key, 
    required this.roomCtrl, 
    required this.onSearch, 
    required this.onOpenFilters,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 1.4),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
            ),
            child: TextField(
              controller: roomCtrl,
              decoration: const InputDecoration(
                hintText: 'Search room...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _SquareButton(icon: Icons.tune, onTap: onOpenFilters),
        const SizedBox(width: 8),
        _SquareButton(
          icon: isLoading ? Icons.hourglass_empty : Icons.search, 
          onTap: isLoading ? null : onSearch,
          isPrimary: true,
        ),
      ],
    );
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _SquareButton({required this.icon, this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandColors>()!;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: isPrimary ? brand.accentYellow : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 1.4),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}