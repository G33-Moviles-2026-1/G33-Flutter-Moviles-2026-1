import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_theme_extension.dart';
import '../../../rooms/domain/entities/room_search.dart';
import '../controllers/path_notifier.dart';
import '../controllers/path_state.dart';

class PathBody extends ConsumerStatefulWidget {
  const PathBody({super.key, this.initialDestination});

  final RoomSearchItem? initialDestination;

  @override
  ConsumerState<PathBody> createState() => _PathBodyState();
}

class _PathBodyState extends ConsumerState<PathBody> {
  final _originFocus = FocusNode();
  final _destFocus = FocusNode();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _originFocus.addListener(_onFocusChange);
    _destFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final editing = _originFocus.hasFocus || _destFocus.hasFocus;
    if (editing != _isEditing) setState(() => _isEditing = editing);
  }

  @override
  void dispose() {
    _originFocus.removeListener(_onFocusChange);
    _destFocus.removeListener(_onFocusChange);
    _originFocus.dispose();
    _destFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pathControllerProvider(widget.initialDestination));
    final notifier =
        ref.read(pathControllerProvider(widget.initialDestination).notifier);

    final t = Theme.of(context);
    final brand = t.extension<BrandColors>()!;
    final isDark = t.brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('Where Are You?', t),
              const SizedBox(height: 8),
              _LocationField(
                value: state.originText,
                validationError: state.originValidationError,
                isLocating: state.isLocatingOrigin,
                focusNode: _originFocus,
                onChanged: notifier.updateOriginText,
                onLocate: () => _handleLocate(context, notifier),
                showGpsButton: true,
                isDark: isDark,
                t: t,
                brand: brand,
              ),
              const SizedBox(height: 20),
              _SectionTitle('Where Do You Want to Go?', t),
              const SizedBox(height: 8),
              _LocationField(
                value: state.destText,
                validationError: state.destValidationError,
                isLocating: false,
                focusNode: _destFocus,
                onChanged: notifier.updateDestText,
                onLocate: () {},
                showGpsButton: false,
                isDark: isDark,
                t: t,
                brand: brand,
              ),
              if (state.hasPath) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _SectionTitle('Follow these steps:', t)),
                    Text(
                      'Est. ${state.path!.formattedDuration}',
                      style: t.textTheme.bodyMedium?.copyWith(
                        color: t.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ],
          ),
        ),

        Expanded(
          child: state.hasPath
              ? ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  itemCount: state.path!.steps.length,
                  itemBuilder: (_, i) => _StepCard(
                    index: i,
                    step: state.path!.steps[i],
                    brand: brand,
                    isDark: isDark,
                    t: t,
                  ),
                )
              : const SizedBox.shrink(),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CacheNavRow(
                state: state,
                isEditing: _isEditing,
                onPrev: notifier.goToPrevious,
                onNext: notifier.goToNext,
                brand: brand,
                t: t,
              ),
              const SizedBox(height: 12),
              _SubmitButton(
                isLoading: state.isLoadingPath,
                onPressed: () => _handleSubmit(context, notifier),
                brand: brand,
                t: t,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleLocate(
      BuildContext context, PathNotifier notifier) async {
    try {
      await notifier.locateOrigin();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(notifier.mapError(e)),
          duration: const Duration(seconds: 4),
        ));
    }
  }

  Future<void> _handleSubmit(
      BuildContext context, PathNotifier notifier) async {
    _originFocus.unfocus();
    _destFocus.unfocus();
    try {
      await notifier.submit();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(notifier.mapError(e)),
          duration: const Duration(seconds: 4),
        ));
    }
  }
}


class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.t);
  final String title;
  final ThemeData t;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: t.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w900,
        fontSize: 22,
      ),
    );
  }
}

class _LocationField extends StatefulWidget {
  const _LocationField({
    required this.value,
    required this.validationError,
    required this.isLocating,
    required this.focusNode,
    required this.onChanged,
    required this.onLocate,
    required this.showGpsButton,
    required this.isDark,
    required this.t,
    required this.brand,
  });

  final String value;
  final String? validationError;
  final bool isLocating;
  final bool showGpsButton;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onLocate;
  final bool isDark;
  final ThemeData t;
  final BrandColors brand;

  @override
  State<_LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<_LocationField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_LocationField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != widget.value) {
      _controller.text = widget.value;
      _controller.selection =
          TextSelection.collapsed(offset: widget.value.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.validationError != null;
    final defaultBorderColor = widget.isDark ? Colors.white24 : Colors.black;
    final borderColor =
        hasError ? widget.t.colorScheme.error : defaultBorderColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.isDark ? Colors.transparent : Colors.black12,
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: widget.focusNode,
                  onChanged: widget.onChanged,
                  maxLength: 50,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z0-9 \-\.,]'),
                    ),
                  ],
                  style: widget.t.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
              if (widget.showGpsButton)
                GestureDetector(
                  onTap: widget.isLocating ? null : widget.onLocate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    child: widget.isLocating
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: widget.brand.accentYellow,
                            ),
                          )
                        : const Icon(Icons.gps_not_fixed,
                            size: 22, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              widget.validationError!,
              style: widget.t.textTheme.bodySmall
                  ?.copyWith(color: widget.t.colorScheme.error),
            ),
          ),
        ],
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.step,
    required this.brand,
    required this.isDark,
    required this.t,
  });

  final int index;
  final String step;
  final BrandColors brand;
  final bool isDark;
  final ThemeData t;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? brand.accentYellow.withValues(alpha: 0.10)
              : const Color(0xFFFFF9C4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? brand.accentYellow.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 12, top: 1),
              decoration: BoxDecoration(
                color: brand.accentYellow,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: t.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                step,
                style: t.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CacheNavRow extends StatelessWidget {
  const _CacheNavRow({
    required this.state,
    required this.isEditing,
    required this.onPrev,
    required this.onNext,
    required this.brand,
    required this.t,
  });

  final PathState state;
  final bool isEditing;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final BrandColors brand;
  final ThemeData t;

  @override
  Widget build(BuildContext context) {
    final canPrev = !isEditing && state.canGoPrev;
    final canNext = !isEditing && state.canGoNext;
    final dimColor = t.colorScheme.onSurface.withValues(alpha: 0.3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: canPrev ? onPrev : null,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          style: IconButton.styleFrom(
            foregroundColor: canPrev ? t.colorScheme.onSurface : dimColor,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          state.cacheSize > 0
              ? '${state.cacheIndex + 1} / ${state.cacheSize}'
              : '- / -',
          style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: canNext ? onNext : null,
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          style: IconButton.styleFrom(
            foregroundColor: canNext ? t.colorScheme.onSurface : dimColor,
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isLoading,
    required this.onPressed,
    required this.brand,
    required this.t,
  });

  final bool isLoading;
  final VoidCallback onPressed;
  final BrandColors brand;
  final ThemeData t;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: brand.accentYellow,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          elevation: 4,
          shadowColor: Colors.black,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Text(
                'Show me the way',
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
      ),
    );
  }
}
