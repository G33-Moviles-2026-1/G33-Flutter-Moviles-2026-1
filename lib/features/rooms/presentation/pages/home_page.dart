import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentTab: AppTab.rooms,
      onTabSelected: (tab) {
        // For now do nothing
      },
      body: Center(
        child: Text(
          'Home content goes here',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}