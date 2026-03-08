import 'package:andespace/shared/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.title = 'AndeSpace',
    this.onTapLeft,
    this.onTapRight,
    this.leftIconPath = 'assets/icons/profile.svg',
    this.rightIconPath = 'assets/icons/search.svg',
  });

  final String title;
  final VoidCallback? onTapLeft;
  final VoidCallback? onTapRight;
  final String leftIconPath;
  final String rightIconPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;

    return AppBar(
      backgroundColor: brand.headerBackground,
      foregroundColor: brand.headerForeground,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: onTapLeft,
        icon: SvgPicture.asset(
          leftIconPath,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            brand.headerForeground,
            BlendMode.srcIn,
          ),
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: brand.headerForeground,
        ),
      ),
      actions: [
        IconButton(
          onPressed: onTapRight,
          icon: SvgPicture.asset(
            rightIconPath,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              brand.headerForeground,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}