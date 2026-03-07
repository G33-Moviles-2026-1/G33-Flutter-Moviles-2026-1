import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/shared/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;

  int get _currentIndex {
    switch (currentTab) {
      case AppTab.rooms:
        return 0;
      case AppTab.favorites:
        return 1;
      case AppTab.bookings:
        return 2;
      case AppTab.schedule:
        return 3;
    }
  }

  Widget _icon(
    BuildContext context,
    String assetPath,
    bool selected,
  ) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;

    return SvgPicture.asset(
      assetPath,
      width: 26,
      height: 26,
      colorFilter: ColorFilter.mode(
        selected ? brand.footerSelected : brand.footerUnselected,
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).extension<BrandColors>()!;

    return BottomNavigationBar(
      backgroundColor: brand.footerBackground,
      currentIndex: _currentIndex,
      onTap: (index) => onTabSelected(AppTab.values[index]),
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 0,
      items: [
        BottomNavigationBarItem(
          icon: _icon(
            context,
            'assets/icons/rooms.svg',
            currentTab == AppTab.rooms,
          ),
          label: 'Rooms',
        ),
        BottomNavigationBarItem(
          icon: _icon(
            context,
            'assets/icons/favorites.svg',
            currentTab == AppTab.favorites,
          ),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: _icon(
            context,
            'assets/icons/bookings.svg',
            currentTab == AppTab.bookings,
          ),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: _icon(
            context,
            'assets/icons/schedule.svg',
            currentTab == AppTab.schedule,
          ),
          label: 'Schedule',
        ),
      ],
    );
  }
}