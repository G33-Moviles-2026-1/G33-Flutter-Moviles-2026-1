import 'package:flutter/material.dart';
import 'app_footer.dart';
import 'app_header.dart';
import '../../features/rooms/presentation/pages/home_page.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    required this.currentTab,
    required this.onTabSelected,
    this.onTapHeaderLeft,
    this.onTapHeaderRight,
    this.title = 'AndeSpace',
  });

  final Widget body;
  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;
  final VoidCallback? onTapHeaderLeft;
  final VoidCallback? onTapHeaderRight;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: title,
        onTapLeft: onTapHeaderLeft,
        onTapRight: onTapHeaderRight,
        onTapTitle: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        },
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: AppFooter(
        currentTab: currentTab,
        onTabSelected: onTabSelected,
      ),
    );
  }
}
