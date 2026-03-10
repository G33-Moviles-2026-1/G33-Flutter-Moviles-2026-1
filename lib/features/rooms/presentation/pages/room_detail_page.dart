import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/features/rooms/presentation/widgets/room_detail_body.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/room_search.dart';

class RoomDetailPage extends StatelessWidget {
  final RoomSearchItem room;
  const RoomDetailPage({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentTab: AppTab.rooms,
      onTabSelected: (_) {
      },
      body: RoomDetailBody(room: room),
    );
  }
}