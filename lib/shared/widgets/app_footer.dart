import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AppTab { rooms, favorites, bookings, schedule }

class AppFooter extends StatelessWidget {
  const AppFooter({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;

  int get _index => AppTab.values.indexOf(currentTab);

  Widget _icon(String asset, bool selected, BuildContext context) {
    final color = Theme.of(context).colorScheme.onPrimary;

    return SvgPicture.asset(
      asset,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _index,
      onTap: (i) => onTabSelected(AppTab.values[i]),
      items: [
        BottomNavigationBarItem(
          icon: _icon('assets/icons/rooms.svg', currentTab == AppTab.rooms, context),
          label: 'Rooms',
        ),
        BottomNavigationBarItem(
          icon: _icon('assets/icons/favorites.svg', currentTab == AppTab.favorites, context),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: _icon('assets/icons/bookings.svg', currentTab == AppTab.bookings, context),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: _icon('assets/icons/schedule.svg', currentTab == AppTab.schedule, context),
          label: 'Schedule',
        ),
      ],
    );
  }
}