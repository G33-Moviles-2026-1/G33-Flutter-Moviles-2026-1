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