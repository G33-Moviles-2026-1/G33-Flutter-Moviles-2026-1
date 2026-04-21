import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/features/rooms/presentation/controllers/home_search_state.dart';
import 'package:andespace/core/utils/date_time_utils.dart';
import 'package:andespace/features/rooms/presentation/controllers/home_search_notifier.dart';
import 'package:andespace/shared/theme/app_theme_extension.dart';
import 'package:andespace/features/rooms/data/cache/home_search_params_memory_cache.dart';
import 'package:andespace/features/rooms/presentation/providers/rooms_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class HomeBody extends ConsumerStatefulWidget {
  const HomeBody({super.key});

  @override
  ConsumerState<HomeBody> createState() => _HomeBodyState();
}

Color _homeFieldColor(BuildContext context) {
  final theme = Theme.of(context);
  return theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface;
}

class _HomeBodyState extends ConsumerState<HomeBody> {
  final _roomInputCtrl = TextEditingController();
  bool _isApplyingCachedValues = false;

  DateTime? _selectedDate;
  TimeOfDay? _since;
  TimeOfDay? _until;
  bool _closeToMe = false;
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

  static const double _topControlHeight = 56;

  @override
  void initState() {
    super.initState();

    _roomInputCtrl.addListener(_onRoomInputChanged);

    final cache = ref.read(homeSearchParamsMemoryCacheProvider);
    final cached = cache.snapshot;

    if (cached != null) {
      _isApplyingCachedValues = true;
      _roomInputCtrl.text = cached.rawRoomInput;
      _selectedDate = cached.selectedDate;
      _since = cached.since;
      _until = cached.until;
      _closeToMe = cached.nearMe;
      _selectedUtilities
        ..clear()
        ..addAll(cached.selectedUtilities);
      _isApplyingCachedValues = false;
      return;
    }

    final now = TimeOfDay.now();
    _selectedDate = DateTime.now();
    _since = now;
    _until = _addMinutes(now, 90);
    _persistCurrentParams();
  }

  @override
  void dispose() {
    _roomInputCtrl.removeListener(_onRoomInputChanged);
    _roomInputCtrl.dispose();
    super.dispose();
  }

  TimeOfDay _addMinutes(TimeOfDay t, int minutesToAdd) {
    final totalMinutes = t.hour * 60 + t.minute + minutesToAdd;
    final normalized = totalMinutes % (24 * 60);
    final h = normalized ~/ 60;
    final m = normalized % 60;
    return TimeOfDay(hour: h, minute: m);
  }

  void _onRoomInputChanged() {
    if (_isApplyingCachedValues) return;
    _persistCurrentParams();
  }

  void _persistCurrentParams() {
    ref.read(homeSearchParamsMemoryCacheProvider).save(
      HomeSearchParamsSnapshot(
        rawRoomInput: _roomInputCtrl.text,
        selectedUtilities: Set<String>.from(_selectedUtilities),
        selectedDate: _selectedDate == null
            ? null
            : DateTime(
                _selectedDate!.year,
                _selectedDate!.month,
                _selectedDate!.day,
              ),
        since: _since == null
            ? null
            : TimeOfDay(hour: _since!.hour, minute: _since!.minute),
        until: _until == null
            ? null
            : TimeOfDay(hour: _until!.hour, minute: _until!.minute),
        nearMe: _closeToMe,
      ),
    );
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
    _persistCurrentParams();
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
    _persistCurrentParams();
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: true);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return DateTimeUtils.toApiDate(date);
  }

  void _openFiltersSheet() {
    ref.read(homeSearchControllerProvider.notifier).onFiltersOpened();

    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;

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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Filter by utilities',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ..._utilityLabels.entries.map(
                      (entry) => CheckboxListTile(
                        value: _selectedUtilities.contains(entry.key),
                        title: Text(
                          entry.value,
                          style: theme.textTheme.bodyLarge,
                        ),
                        contentPadding: EdgeInsets.zero,
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return brand.accentYellow;
                          }
                          return Colors.transparent;
                        }),
                        checkColor: theme.colorScheme.onSecondary,
                        side: BorderSide(
                          color: theme.colorScheme.onSurface,
                          width: 1.2,
                        ),
                        onChanged: (checked) {
                          setState(() {
                            if (checked ?? false) {
                              _selectedUtilities.add(entry.key);
                            } else {
                              _selectedUtilities.remove(entry.key);
                            }
                          });
                          _persistCurrentParams();
                          modalSetState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.onSurface,
                          foregroundColor: theme.colorScheme.surface,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

  Future<void> _onSearch() async {
    _persistCurrentParams();

    await ref
        .read(homeSearchControllerProvider.notifier)
        .submitSearch(
          rawRoomInput: _roomInputCtrl.text,
          selectedDate: _selectedDate,
          since: _since,
          until: _until,
          selectedUtilities: _selectedUtilities,
          nearMe: _closeToMe,
          offset: 0,
        );

    if (!mounted) return;

    if (ref.read(homeSearchControllerProvider).status ==
        HomeSearchStatus.success) {
      Navigator.pushNamed(context, AppRoutes.results);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<HomeSearchState>(homeSearchControllerProvider, (previous, next) {
      final previousMessage = previous?.feedbackMessage;
      final nextMessage = next.feedbackMessage;

      if (nextMessage != null && nextMessage != previousMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(nextMessage),
              duration: const Duration(seconds: 4),
            ),
          );
      }
    });

    final state = ref.watch(homeSearchControllerProvider);
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;

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
                child: SizedBox(
                  height: _topControlHeight,
                  child: _CardField(
                    child: TextField(
                      controller: _roomInputCtrl,
                      inputFormatters: [LengthLimitingTextInputFormatter(50)],
                      style: theme.textTheme.bodyLarge,
                      maxLines: 1,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'e.g.: "B 201, C 5, ML"',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: _topControlHeight,
                height: _topControlHeight,
                child: _SquareIconButton(
                  tooltip: 'Filters',
                  svgAsset: 'assets/icons/filters.svg',
                  onPressed: _openFiltersSheet,
                ),
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
                      : () {
                          setState(() => _since = null);
                          _persistCurrentParams();
                        },
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
                      : () {
                          setState(() => _until = null);
                          _persistCurrentParams();
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
              // FIX: Flexible lets the label wrap at extreme font sizes
              // without affecting layout at normal sizes.
              Flexible(
                child: Text(
                  'Close to me',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Checkbox(
                value: _closeToMe,
                onChanged: state.isLoading
                    ? null
                    : (value) {
                        setState(() => _closeToMe = value ?? false);
                        _persistCurrentParams();
                      },
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
              label: 'Search',
              isLoading: state.isLoading,
              onPressed: state.isLoading ? null : _onSearch,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Supporting widgets ──────────────────────────────────────────────────────

class _CardField extends StatelessWidget {
  const _CardField({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: _homeFieldColor(context),
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
      child: SizedBox.expand(child: child),
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
      color: _homeFieldColor(context),
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: SizedBox.expand(
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
      color: _homeFieldColor(context),
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        value,
                        style: theme.textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
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
      color: _homeFieldColor(context),
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onClear != null) ...[
                      GestureDetector(
                        onTap: onClear,
                        child: const Icon(Icons.close, size: 18),
                      ),
                      const SizedBox(width: 6),
                    ],
                    SvgPicture.asset(
                      'assets/icons/clock.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        value,
                        style: theme.textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;
    final isEnabled = onPressed != null;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: brand.accentYellow,
        foregroundColor: theme.colorScheme.onSecondary,
        disabledBackgroundColor: brand.accentYellow,
        disabledForegroundColor: theme.colorScheme.onSecondary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: theme.brightness == Brightness.light
              ? BorderSide(color: theme.colorScheme.onSurface, width: 1.4)
              : BorderSide.none,
        ),
        textStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: isLoading
            ? Row(
                key: const ValueKey('loading'),
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Searching...',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                ],
              )
            : Text(
                label,
                key: const ValueKey('idle'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isEnabled
                      ? theme.colorScheme.onSecondary
                      : theme.colorScheme.onSecondary,
                ),
              ),
      ),
    );
  }
}
