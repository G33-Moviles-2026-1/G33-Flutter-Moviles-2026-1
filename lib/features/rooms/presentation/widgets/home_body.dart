import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/theme/theme.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final _classroomCtrl = TextEditingController();
  TimeOfDay? _since;
  TimeOfDay? _until;
  bool _closeToMe = true;

  @override
  void dispose() {
    _classroomCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _since = now;
    _until = _addMinutes(now, 90);
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

  String _formatTime(TimeOfDay? t) {
    if (t == null) return '--:--';
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(t, alwaysUse24HourFormat: false);
  }

  void _openFiltersSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Utilities Filters',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'Filters UI goes here (tomorrow we wire it to real logic).',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _onSearch() {
    // TODO:
    final since = _formatTime(_since);
    final until = _formatTime(_until);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Search: "${_classroomCtrl.text}" | Since: $since | Until: $until | Close: $_closeToMe',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 6),

          // Main title
          Text(
            'Where do you\nwant to go?',
            textAlign: TextAlign.center,
            style: t.textTheme.headlineLarge?.copyWith(
              fontSize: 34,
              height: 1.05,
            ),
          ),

          const SizedBox(height: 18),

          // Classroom search row: input + filter icon button
          Row(
            children: [
              Expanded(
                child: _CardField(
                  child: TextField(
                    controller: _classroomCtrl,
                    style: t.textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: 'Classroom ej. ML 201, ML 5, ML',
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

          // Since / Until row
          Row(
            children: [
              Expanded(
                child: _TimeBox(
                  label: 'Since',
                  value: _formatTime(_since),
                  onTap: () => _pickTime(isSince: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TimeBox(
                  label: 'Until',
                  value: _formatTime(_until),
                  onTap: () => _pickTime(isSince: false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Close to me row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/location.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.black,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Close to me',
                style: t.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              Checkbox(
                value: _closeToMe,
                onChanged: (v) => setState(() => _closeToMe = v ?? false),
                activeColor: AppColors.accentYellow,
                checkColor: AppColors.black,
                side: const BorderSide(color: AppColors.black, width: 1.2),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // CTA Search button
          SizedBox(
            width: double.infinity,
            child: _CtaButton(label: 'Search', onPressed: _onSearch),
          ),
        ],
      ),
    );
  }
}

/// --- UI building blocks (keep HomeBody clean) ---

class _CardField extends StatelessWidget {
  const _CardField({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 3),
            color: Color(0x22000000),
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
    return Material(
      color: AppColors.white,
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
              colorFilter: const ColorFilter.mode(
                AppColors.black,
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

class _TimeBox extends StatelessWidget {
  const _TimeBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Material(
      color: AppColors.white,
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
                style: t.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              SvgPicture.asset(
                'assets/icons/clock.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.black,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value.isEmpty ? '--:--' : value,
                style: t.textTheme.bodyLarge,
              ),
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
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentYellow,
        foregroundColor: AppColors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.black, width: 1.4),
        ),
        textStyle: t.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Text(label),
    );
  }
}
