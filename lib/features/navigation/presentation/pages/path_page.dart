import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

import '../widgets/path_body.dart';

class PathPage extends StatelessWidget {
  const PathPage({super.key, this.initialDestination});

  final RoomSearchItem? initialDestination;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentTab: AppTab.path,
      onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
      body: PathBody(initialDestination: initialDestination),
    );
  }
}