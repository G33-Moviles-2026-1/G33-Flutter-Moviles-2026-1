import 'package:flutter/material.dart';

class RoomCardBadge extends StatelessWidget {
  const RoomCardBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: foregroundColor,
        ),
      ),
    );
  }
}

class OutlinedHeartIcon extends StatelessWidget {
  const OutlinedHeartIcon({
    super.key,
    required this.isFilled,
    required this.fillColor,
  });

  final bool isFilled;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            isFilled ? Icons.favorite : Icons.favorite_border,
            size: 23,
            color: Colors.black,
          ),
          Icon(
            isFilled ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: fillColor,
          ),
        ],
      ),
    );
  }
}

class RoomCardContainer extends StatelessWidget {
  const RoomCardContainer({
    super.key,
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: .18),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class RoomCardHeaderRow extends StatelessWidget {
  const RoomCardHeaderRow({
    super.key,
    required this.roomId,
    required this.trailing,
  });

  final String roomId;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            roomId,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ...trailing,
      ],
    );
  }
}