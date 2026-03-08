import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../theme/theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.onTapLeft,
    this.onTapRight,
    this.onTapTitle,
    this.title = 'AndeSpace',
  });

  final VoidCallback? onTapLeft;
  final VoidCallback? onTapRight;
  final VoidCallback? onTapTitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      elevation: 0,
      centerTitle: true,

      leading: IconButton(
        onPressed: onTapLeft,
        tooltip: 'History',
        icon: SvgPicture.asset(
          'assets/icons/history.svg',
          width: 30,
          height: 30,
          colorFilter: const ColorFilter.mode(
            AppColors.black,
            BlendMode.srcIn,
          ),
        ),
      ),

      title: InkWell(
        onTap: onTapTitle,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          // makes it easier to tap the title
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 30,
              color: AppColors.black,
            ),
          ),
        ),
      ),

      actions: [
        IconButton(
          onPressed: onTapRight,
          tooltip: 'User',
          icon: SvgPicture.asset(
            'assets/icons/user.svg',
            width: 30,
            height: 30,
            colorFilter: const ColorFilter.mode(
              AppColors.black,
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