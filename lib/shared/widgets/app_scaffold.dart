import 'package:andespace/core/navigation/app_tab.dart';
import 'package:flutter/material.dart';
import 'app_footer.dart';
import 'app_header.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    required this.currentTab,
    required this.onTabSelected,
    this.onTapHeaderLeft,
    this.onTapHeaderRight,
    this.title = 'AndeSpace',
    this.extendBody = false,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;
  final VoidCallback? onTapHeaderLeft;
  final VoidCallback? onTapHeaderRight;
  final String title;
  final bool extendBody;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      appBar: AppHeader(
        title: title,
        onTapLeft: onTapHeaderLeft,
        onTapRight: onTapHeaderRight,
      ),
      body: SafeArea(
        child: body,
      ),
      bottomNavigationBar: AppFooter(
        currentTab: currentTab,
        onTabSelected: onTabSelected,
      ),
    );
  }
}