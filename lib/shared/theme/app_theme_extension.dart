import 'package:flutter/material.dart';

@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  final Color softYellow;
  final Color accentYellow;
  final Color headerBackground;
  final Color footerBackground;
  final Color headerForeground;
  final Color footerSelected;
  final Color footerUnselected;

  const BrandColors({
    required this.softYellow,
    required this.accentYellow,
    required this.headerBackground,
    required this.footerBackground,
    required this.headerForeground,
    required this.footerSelected,
    required this.footerUnselected,
  });

  @override
  BrandColors copyWith({
    Color? softYellow,
    Color? accentYellow,
    Color? headerBackground,
    Color? footerBackground,
    Color? headerForeground,
    Color? footerSelected,
    Color? footerUnselected,
  }) {
    return BrandColors(
      softYellow: softYellow ?? this.softYellow,
      accentYellow: accentYellow ?? this.accentYellow,
      headerBackground: headerBackground ?? this.headerBackground,
      footerBackground: footerBackground ?? this.footerBackground,
      headerForeground: headerForeground ?? this.headerForeground,
      footerSelected: footerSelected ?? this.footerSelected,
      footerUnselected: footerUnselected ?? this.footerUnselected,
    );
  }

  @override
  BrandColors lerp(ThemeExtension<BrandColors>? other, double t) {
    if (other is! BrandColors) return this;
    return BrandColors(
      softYellow: Color.lerp(softYellow, other.softYellow, t)!,
      accentYellow: Color.lerp(accentYellow, other.accentYellow, t)!,
      headerBackground: Color.lerp(headerBackground, other.headerBackground, t)!,
      footerBackground: Color.lerp(footerBackground, other.footerBackground, t)!,
      headerForeground: Color.lerp(headerForeground, other.headerForeground, t)!,
      footerSelected: Color.lerp(footerSelected, other.footerSelected, t)!,
      footerUnselected: Color.lerp(footerUnselected, other.footerUnselected, t)!,
    );
  }
}