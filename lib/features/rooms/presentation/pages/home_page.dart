import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

import '../widgets/home_body.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentTab: AppTab.rooms,
      onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
      body: const HomeBody(),
    );
  }
}