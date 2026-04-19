import 'package:flutter/material.dart';

Future<T?> showAnchoredPopupDialog<T>({
  required BuildContext context,
  required String barrierLabel,
  required WidgetBuilder builder,
  double top = 70,
  double? left,
  double? right,
  double width = 280,
  EdgeInsetsGeometry padding = const EdgeInsets.all(18),
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return showGeneralDialog<T>(
    context: context,
    barrierLabel: barrierLabel,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: top,
              left: left,
              right: right,
              child: Material(
                color: Colors.transparent,
                child: AnchoredPopupDialogCard(
                  width: width,
                  padding: padding,
                  backgroundColor: theme.cardColor,
                  borderColor: isDark ? Colors.white10 : Colors.black12,
                  child: builder(dialogContext),
                ),
              ),
            ),
          ],
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );

      return FadeTransition(
        opacity: curved,
        child: child,
      );
    },
  );
}

class AnchoredPopupDialogCard extends StatelessWidget {
  const AnchoredPopupDialogCard({
    super.key,
    required this.width,
    required this.padding,
    required this.backgroundColor,
    required this.borderColor,
    required this.child,
  });

  final double width;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.18),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}