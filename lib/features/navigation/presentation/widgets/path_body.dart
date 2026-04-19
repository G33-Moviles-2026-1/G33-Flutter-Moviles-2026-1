import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_theme_extension.dart';
import '../../../rooms/domain/entities/room_search.dart';
import '../controllers/path_notifier.dart';

class PathBody extends ConsumerWidget {
  const PathBody({super.key, this.initialDestination});

  final RoomSearchItem? initialDestination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pathControllerProvider(initialDestination));
    final notifier = ref.read(pathControllerProvider(initialDestination).notifier);

    ref.listen(pathControllerProvider(initialDestination), (prev, next) {
    });

    final t = Theme.of(context);
    final brand = t.extension<BrandColors>()!;
    final isDark = t.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Where Are You?', t),
          const SizedBox(height: 8),
          _LocationField(
            value: state.originText,
            validationError: state.originValidationError,
            isLocating: state.isLocatingOrigin,
            onChanged: notifier.updateOriginText,
            onLocate: () => _handleLocate(context, notifier),
            showGpsButton: true,
            isDark: isDark,
            t: t,
            brand: brand,
          ),
          const SizedBox(height: 24),
          _SectionTitle('Where Do You Want to Go?', t),
          const SizedBox(height: 8),
          _LocationField(
            value: state.destText,
            validationError: state.destValidationError,
            isLocating: false,
            onChanged: notifier.updateDestText,
            onLocate: () {},
            showGpsButton: false,
            isDark: isDark,
            t: t,
            brand: brand,
          ),
          const SizedBox(height: 32),
          if (state.hasPath) ...[
            _SectionTitle('Follow these steps:', t),
            const SizedBox(height: 4),
            Text(
              'Estimated time: ${state.path!.formattedDuration}',
              style: t.textTheme.bodyMedium?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _StepsContainer(
                steps: state.path!.steps,
                brand: brand,
                isDark: isDark,
                t: t),
            const SizedBox(height: 40),
          ] else
            const SizedBox(height: 40),
          _SubmitButton(
            isLoading: state.isLoadingPath,
            onPressed: () => _handleSubmit(context, notifier),
            brand: brand,
            t: t,
          ),
          const SizedBox(height: 24),
        ],
      ),
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
    final borderColor = hasError
        ? widget.t.colorScheme.error
        : widget.isDark
            ? Colors.white24
            : Colors.black;

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

class _StepsContainer extends StatelessWidget {
  const _StepsContainer({
    required this.steps,
    required this.brand,
    required this.isDark,
    required this.t,
  });

  final List<String> steps;
  final BrandColors brand;
  final bool isDark;
  final ThemeData t;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? brand.accentYellow.withValues(alpha: 0.15)
            : const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? brand.accentYellow
              : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: steps
            .asMap()
            .entries
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${e.key + 1}. ',
                      style:
                          t.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(
                        e.value,
                        style: t.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
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