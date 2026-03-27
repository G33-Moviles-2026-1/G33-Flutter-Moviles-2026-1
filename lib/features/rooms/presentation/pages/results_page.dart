import 'package:andespace/features/rooms/presentation/providers/rooms_providers.dart';
import 'package:andespace/features/rooms/presentation/widgets/results_body.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class ResultsPage extends ConsumerWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeSearchControllerProvider);

    return AppScaffold(
      //title: 'Results',
      currentTab: AppTab.rooms,
      onTabSelected: (_) {},
      body: ResultsBody(state: state),
    );
  }
}