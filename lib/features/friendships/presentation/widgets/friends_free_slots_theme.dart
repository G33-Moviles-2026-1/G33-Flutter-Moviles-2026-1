import 'package:flutter/material.dart';

Color friendsFreeSlotsPanelBackground(BuildContext context) {
  final theme = Theme.of(context);
  return theme.brightness == Brightness.dark
      ? const Color(0xFF1A1D22)
      : Colors.white;
}

Color friendsFreeSlotsGridBorderColor(BuildContext context) {
  return Theme.of(context).dividerColor.withValues(alpha: 0.18);
}

Color friendsFreeSlotsEmptySlotBackground(BuildContext context) {
  final theme = Theme.of(context);
  return theme.colorScheme.onSurface.withValues(alpha: 0.04);
}

Color friendsFreeSlotsActionOrange(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFFFA500)
      : const Color(0xFFFCBD00);
}
