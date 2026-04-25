import 'dart:async';
import 'dart:io';

import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/shared/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppFooter extends StatefulWidget {
  const AppFooter({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;

  @override
  State<AppFooter> createState() => _AppFooterState();
}

class _AppFooterState extends State<AppFooter> {
  bool _isOnline = true;
  Timer? _timer;

  int get _currentIndex {
    switch (widget.currentTab) {
      case AppTab.rooms:
        return 0;
      case AppTab.favorites:
        return 1;
      case AppTab.path:
        return 2;
      case AppTab.bookings:
        return 3;
      case AppTab.schedule:
        return 4;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkConnection(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 2));

      final online = result.isNotEmpty && result.first.rawAddress.isNotEmpty;

      if (mounted && online != _isOnline) {
        setState(() => _isOnline = online);
      }
    } catch (_) {
      if (mounted && _isOnline) {
        setState(() => _isOnline = false);
      }
    }
  }

  Widget _icon(BuildContext context, String assetPath, bool selected) {
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
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: _isOnline ? 0 : 30,
          width: double.infinity,
          curve: Curves.easeInOut,
          color: brand.footerSelected.withValues(alpha: 0.9),
          alignment: Alignment.center,
          child: _isOnline
              ? const SizedBox.shrink()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 14,
                      color: brand.footerBackground,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "You're offline",
                      style: TextStyle(
                        color: brand.footerBackground,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
        ),
        BottomNavigationBar(
          backgroundColor: brand.footerBackground,
          currentIndex: _currentIndex,
          onTap: (index) => widget.onTabSelected(AppTab.values[index]),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _icon(
                context,
                'assets/icons/rooms.svg',
                widget.currentTab == AppTab.rooms,
              ),
              label: 'Rooms',
            ),
            BottomNavigationBarItem(
              icon: _icon(
                context,
                'assets/icons/favorites.svg',
                widget.currentTab == AppTab.favorites,
              ),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: _icon(
                context,
                'assets/icons/path.svg',
                widget.currentTab == AppTab.path,
              ),
              label: 'Path',
            ),
            BottomNavigationBarItem(
              icon: _icon(
                context,
                'assets/icons/bookings.svg',
                widget.currentTab == AppTab.bookings,
              ),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: _icon(
                context,
                'assets/icons/schedule.svg',
                widget.currentTab == AppTab.schedule,
              ),
              label: 'Schedule',
            ),
          ],
        ),
      ],
    );
  }
}
